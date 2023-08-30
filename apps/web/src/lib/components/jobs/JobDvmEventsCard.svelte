<script lang="ts">
	import { NDKDVMJobResult, NDKDVMJobFeedback, NDKDVMRequest, NDKAppHandlerEvent, type NDKUserProfile, NDKKind, NDKEvent } from "@nostr-dev-kit/ndk";
	import JobResultRow from "./JobResultRow.svelte";
	import { appHandlers } from "$stores/nip89";
	import { findNip89Event } from "$utils/nip89";
	import { Avatar, EventContent, Name } from "@nostr-dev-kit/ndk-svelte-components";
	import ndk from "$stores/ndk";
	import Time from "svelte-time/src/Time.svelte";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import JobStatusLabel from "./JobStatusLabel.svelte";
	import PaymentRequiredButton from "./PaymentRequiredButton.svelte";
	import DvmListItem from "$components/dvms/DvmListItem.svelte";
	import { ElementConnector } from "@kind0/ui-common";
	import { Heart } from "phosphor-svelte";
	import EventCard from "./EventCard.svelte";

    export let jobRequest: NDKDVMRequest;
    export let dvmPubkey: string;
    export let events: NDKEventStore<NDKEvent>;
	export let parentElement: HTMLElement;

    let nip89event: NDKAppHandlerEvent | undefined;

    let paymentPending = false;
    let paymentPendingEvent: NDKDVMJobFeedback | undefined;

    $: if ($appHandlers && !nip89event) nip89event = findNip89Event(dvmPubkey, jobRequest.kind!);

    // check if the most recent event has an amount tag
    $: paymentPending = $events[$events.length-1]?.getMatchingTags('amount').length > 0;
    $: paymentPendingEvent = $events.find((event) => event.getMatchingTags('amount').length > 0);

    let profile: NDKUserProfile | undefined;
    let fetchingProfile = false;

	let fetchProfilePromise = new Promise((resolve, reject) => {
		if (nip89event) {
			nip89event.fetchProfile().then((p) => {
				profile = p;
				resolve(p);
			});
		} else {
			const user = $ndk.getUser({ hexpubkey: dvmPubkey });
			if (user) {
				user.fetchProfile().then((p) => {
					profile = user.profile;
					resolve(profile);
				});
			}
		}
	});

    $: if (nip89event && !profile && !fetchingProfile) {
        fetchingProfile = true;
        nip89event.fetchProfile().then((p) => {
			console.log('here, setting fetchingProfile to false')
            fetchingProfile = false;
            profile = p;
        });
    }

    let jobResults: NDKDVMJobResult[] = [];
    let mostRecentEvent: NDKEvent | undefined;

    $: jobResults = $events
        .filter((event) => event.kind === NDKKind.DVMJobResult)
        .map((event) => NDKDVMJobResult.from(event));

    $: mostRecentEvent = $events[$events.length-1];

    function hasJobResult() {
        return jobResults.length > 0;
    }

    function useRelativeTime(event: NDKEvent) {
        const now = Date.now();
        const diff = now - (event.created_at! * 1000);

        return diff < 1000*60*60*24;
    }

    let containerClass: string = "";

    $: if (paymentPending && paymentPendingEvent) {
        containerClass = "";
    } else if (!fetchingProfile) {
        containerClass = "col-span-2";
    }
</script>

{#await fetchProfilePromise then}
<ElementConnector from={parentElement} class={containerClass}>
    {#if paymentPending && paymentPendingEvent}
        {#if nip89event}
			<EventCard
				event={mostRecentEvent}
			>
				<div class="flex flex-row items-center gap-2 font-normal text-sm text-base-100-content" slot="header">
					<Avatar ndk={$ndk} userProfile={profile} class="w-8 h-8 rounded-full" />
					<div class="flex flex-row items-center gap-1">
						<span class="truncate max-w-xs inline-block">
							<Name ndk={$ndk} userProfile={profile} class="font-semibold" />
						</span>
					</div>
				</div>

				<div class="flex flex-col items-center md:flex-row gap-4">
					<div class="flex flex-col divide-y divide-base-300 flex-grow">
						<div class="p-4">
							{profile?.about}
						</div>

						{#if mostRecentEvent.content.length > 0}
							<div class="p-4 text-base-100-content text-lg overflow-x-hidden">
								<EventContent
									ndk={$ndk}
									event={paymentPendingEvent}
								/>
							</div>
						{/if}
					</div>

					<div class="p-3">
						<PaymentRequiredButton
							event={paymentPendingEvent}
							class="!uppercase whitespace-nowrap flex-nowrap !text-base w-full"
						/>
					</div>

				</div>


			</EventCard>

            <!-- <DvmListItem dvm={nip89event}>
                <div class="h-full flex flex-col justify-end gap-6">
                    {#if paymentPendingEvent.content.length > 0}
                        <div class="p-2 glass rounded-lg">
                            <div class="bg-base-300 p-4 rounded-lg text-left">
                                <EventContent
                                    event={paymentPendingEvent}
                                />
                            </div>
                        </div>
                    {/if}
                    <PaymentRequiredButton
                        event={paymentPendingEvent}
                        class="!uppercase"
                    />
                </div>
            </DvmListItem> -->
        {:else}
            no nip89 event found
        {/if}
    {:else if !fetchingProfile}
        <div class="card card-compact">
            <div class="card-body">
                <div class="flex flex-col items-start gap-4">
                    <!-- header -->
                    <div class="flex flex-row items-center justify-between w-full">
                        <div class="flex flex-row items-center gap-2 font-normal text-sm text-base-100-content">
                            <Avatar ndk={$ndk} userProfile={profile} class="w-8 h-8 rounded-full" />
                            <div class="flex flex-row items-center gap-1">
                                <span class="truncate max-w-xs inline-block">
                                    <Name ndk={$ndk} userProfile={profile} class="font-semibold" />
                                </span>
                            </div>
                        </div>

                        <Time
                            relative={useRelativeTime(mostRecentEvent)}
                            timestamp={mostRecentEvent.created_at * 1000}
                            class="text-sm whitespace-nowrap"
                        />

                        <JobStatusLabel status={mostRecentEvent?.tagValue('status')} />
                    </div>

                    <!-- body -->
                    <!-- if we have a response, we show that -->
                    {#if hasJobResult()}
                        {#each jobResults as jobResult (jobResult.id)}
                            <JobResultRow event={jobResult} imageClass="max-h-48 rounded-lg" />
                        {/each}
                    {:else}
                        {mostRecentEvent.content}
                    {/if}
                </div>
            </div>
        </div>
    {/if}
</ElementConnector>
{/await}

<style>
	section > * {
		@apply p-3;
	}

    :global(.connector) {
        @apply border-l-8 border-l-base-200;
        @apply border-b-8 border-b-base-200;
    }
</style>