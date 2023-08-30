<script lang="ts">
	import type { NDKDVMJobResult, NDKTag } from "@nostr-dev-kit/ndk";
    import ndk from "$stores/ndk";
	import { Avatar, EventContent, Name, UserCard } from "@nostr-dev-kit/ndk-svelte-components";
	import { onMount } from "svelte";
	import { markEventAsSeen } from "$stores/notifications";
    import { Lightbox } from 'svelte-lightbox'

    export let event: NDKDVMJobResult;
    export let dontMarkAsSeen: boolean = false;
    export let expanded = false;

    const status = event.tagValue("status");

    function contentIsImageUrl() {
        try {
            const url = new URL(event.content);

            return url.pathname.endsWith(".png") || url.pathname.endsWith(".jpg");
        } catch (e) {
            return false;
        }
    }

    let decodedContent: NDKTag[] | undefined;

    try {
        decodedContent = JSON.parse(event.content);
    } catch (e) {}

    let shouldRestrictResultHeight: boolean;

    $: shouldRestrictResultHeight = (
            !contentIsImageUrl() &&
            event.jobRequest?.kind !== 65006
        ) || (
            decodedContent && decodedContent.length > tagsToDisplay
        );

    onMount(() => {
        if (!dontMarkAsSeen) markEventAsSeen(event.id);
    })

    let tagsToDisplay = expanded ? 9999 : 3;
</script>

<div class="
    flex flex-row w-full items-center whitespace-normal
    {event.kind === 65001 ? "text-base" : ""}
">
    <div class="flex-grow overflow-x-clip
        {shouldRestrictResultHeight ? "max-h-48 overflow-y-hidden" : "overflow-y-auto "}
    ">
        {#if event.kind === 65001 && contentIsImageUrl()}
        here
            <Lightbox>
                <img src={event.content} class={$$props.imageClass} />
            </Lightbox>
        {:else if event.jobRequest?.kind && [65006, 65007].includes(event.jobRequest?.kind)}
            {#if decodedContent}
                <div
                    class="flex flex-col divide-y divide-base-300"
                >
                    {#each decodedContent.slice(0, tagsToDisplay) as tag}
                        <div class="flex flex-row gap-4 p-2">
                            {#if tag[0] === "p"}
                                <UserCard ndk={$ndk} pubkey={tag[1]} class="" />
                            {:else if tag[0] === "e"}
                                {#await $ndk.fetchEvent(tag[1]) then event}
                                    <EventContent ndk={$ndk} {event} showMedia={true} />
                                {/await}
                            {:else}
                                {tag[1]}
                            {/if}
                        </div>
                    {/each}

                    {#if decodedContent.length > tagsToDisplay}
                        <button
                            class="absolute top-0 bottom-0 left-0 right-0 flex items-center justify-center bg-base-300 bg-opacity-40 group w-full rounded-box"
                            on:click={() => tagsToDisplay = decodedContent.length}
                        >
                            <div class="flex flex-row items-center justify-center p-2">
                                <button class="btn btn-ghost bg-base-300 !rounded-full group-hover:bg-base-200">
                                    {decodedContent.length} items
                                </button>
                            </div>
                        </button>

                        <div class="
                            flex flex-row justify-center p-2 absolute bottom-0 left-0 right-0
                            h-12
                            bg-gradient-to-t from-base-300 to-transparent
                        ">
                        </div>
                    {/if}

                </div>
            {:else}
                {event.content}
            {/if}
        {:else}
                {event.jobRequest?.kind}
            <EventContent ndk={$ndk} {event} showMedia={true} />
        {/if}
    </div>
</div>