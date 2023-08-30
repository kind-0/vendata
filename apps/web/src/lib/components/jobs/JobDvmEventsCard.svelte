<script lang="ts">
	import {
		NDKDVMJobResult,
		NDKDVMJobFeedback,
		NDKDVMRequest,
		NDKAppHandlerEvent,
		type NDKUserProfile,
		NDKKind,
		NDKEvent
	} from '@nostr-dev-kit/ndk';
	import JobFeedbackRow from './JobFeedbackRow.svelte';
	import JobResultRow from './JobResultRow.svelte';
	import DvmTile from './JobRequestEditor/DvmTile.svelte';
	import { appHandlers } from '$stores/nip89';
	import { findNip89Event } from '$utils/nip89';
	import { Avatar, EventContent, Name } from '@nostr-dev-kit/ndk-svelte-components';
	import ndk from '$stores/ndk';
	import Time from 'svelte-time/src/Time.svelte';
	import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import JobStatusLabel from './JobStatusLabel.svelte';
	import PaymentRequiredButton from './PaymentRequiredButton.svelte';
	import DvmListItem from '$components/dvms/DvmListItem.svelte';

	import StarIcons from '$icons/TestIcons/StarIcons.svelte';
	// Icon for ShowCase Only
	import UserIcon from '$lib/icons/TestIcons/Frame.svg';
	import Account from '$lib/icons/TestIcons/Account.svg';
	import Heart from '$lib/icons/TestIcons/Heart.svg';
	import Bolt from '$lib/icons/TestIcons/Bolt.svg';
	//

	export let jobRequest: NDKDVMRequest;
	export let dvmPubkey: string;
	export let events: NDKEventStore<NDKEvent>;

	let nip89event: NDKAppHandlerEvent | undefined;

	let paymentPending = false;
	let paymentPendingEvent: NDKDVMJobFeedback | undefined;

	$: if ($appHandlers && !nip89event) nip89event = findNip89Event(dvmPubkey, jobRequest.kind!);

	// check if the most recent event has an amount tag
	$: paymentPending = $events[$events.length - 1]?.getMatchingTags('amount').length > 0;
	$: paymentPendingEvent = $events.find((event) => event.getMatchingTags('amount').length > 0);

	let profile: NDKUserProfile | undefined;
	let fetchingProfile = false;

	$: if (nip89event && !profile && !fetchingProfile) {
		fetchingProfile = true;
		nip89event.fetchProfile().then((p) => {
			fetchingProfile = false;
			profile = p;
		});
	}

	let jobResults: NDKDVMJobResult[] = [];
	let mostRecentEvent: NDKEvent | undefined;

	$: jobResults = $events
		.filter((event) => event.kind === NDKKind.DVMJobResult)
		.map((event) => NDKDVMJobResult.from(event));

	$: mostRecentEvent = $events[$events.length - 1];

	function hasJobResult() {
		return jobResults.length > 0;
	}

	function useRelativeTime(event: NDKEvent) {
		const now = Date.now();
		const diff = now - event.created_at! * 1000;

		return diff < 1000 * 60 * 60 * 24;
	}
</script>

<!-- {#if paymentPending && paymentPendingEvent}
    {#if nip89event}
        <DvmListItem dvm={nip89event}>
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
        </DvmListItem>
    {:else}
        no nip89 event found
    {/if}
{:else if !fetchingProfile}
    <div class="card card-compact">
        <div class="card-body">
            <div class="flex flex-col items-start gap-4">
                header
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

                body
                if we have a response, we show that
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
{/if} -->

<!--
<div class="flex flex-col gap-2">
    <DvmCard pubkey={dvmPubkey} kind={jobRequest.kind} />
    <div class="flex flex-col rounded-box bg-base-100 divide-y divide-base-300 gap-4 p-4">
        {#each events as event (event.id)}
            {#if event instanceof NDKDVMJobFeedback}
                <JobFeedbackRow {event} />
            {:else if event instanceof NDKDVMJobResult}
                <JobResultRow {event} />
            {/if}
        {/each}
    </div>
</div> -->

<section class="flex flex-col gap-2 rounded-[22px] bg-[#111] p-3 xl:flex-row xl:w-full ">
	<div class="flex flex-col gap-3 border-b-[1px] border-b-[#232323] pb-3 xl:border-r-[1px] xl:border-b-0 xl:border-r-[#232323] xl:pr-3 xl:pb-0 xl:w-1/4 ">
		<div class="flex gap-3">
			<img src={UserIcon} alt="UserIcon" width="44" height="44" />
			<div class="flex flex-col gap-1">
				<h2>NostrAI DVM Transl...</h2>

				<div class="flex gap-1">
					{#each Array(5) as star}
						<StarIcons starColor={'#817EFF'} />
					{/each}
				</div>
			</div>
		</div>

		<div class="flex items-center justify-between">
			<div class="flex -space-x-3">
				<img class="h-7 w-7 rounded-full" src={Account} alt="" />
				<img class="h-7 w-7 rounded-full" src={Account} alt="" />
				<img class="h-7 w-7 rounded-full" src={Account} alt="" />
				<div
					class="flex h-7 w-[45px] items-center justify-center rounded-2xl bg-[#232323] text-xs font-normal text-white backdrop-blur-md"
				>
					+99
				</div>
			</div>

			<div class="flex items-center gap-2 text-xs font-normal text-white sm:text-sm  ">
				Favor this
				<div
					class="flex h-7 w-7 items-center justify-center rounded-[14px] bg-[#232323] backdrop-blur-md"
				>
					<img src={Heart} alt="Heart" />
				</div>
			</div>
		</div>
	</div>

	<div class=" border-b-[1px] border-b-[#232323] pb-3 text-xs font-normal text-white sm:text-sm xl:border-r-[1px] xl:border-b-0 xl:border-r-[#232323] xl:pr-3 xl:pb-0 xl:w-[45%] ">
		Returns a list of inactive followings. This includes npubs of users who haven't posted or
		reacted within the last x days (default 30). Parameter since can be used to increase the search.
	</div>
	<div class="flex items-center gap-3 flex-col xl:w-[30%]" >
		<button
			on:click
			class=" btn bg-base-100 btn-rounded-full text-base-100-content h-11 w-full rounded-full border-2 border-[#817EFF] text-base font-medium normal-case hover:border-[#817EFF] hover:bg-[#817EFF] hover:bg-opacity-20"
		>
			Pay
			<div class="flex font-semibold " >
				<img src={Bolt} alt="Bolt" />
				210
			</div>
		</button>
		<div class="text-[#B3B3B3] text-xs font-normal text-center sm:text-sm " >
			I see this file is quite large so it’ll probably take me some time to process it. Approx 40 min.
		</div>
	</div>
</section>
