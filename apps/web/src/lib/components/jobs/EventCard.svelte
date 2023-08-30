<script lang="ts">
	import { eventUserReference } from "$utils";
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
    import { Avatar, EventCardDropdownMenu, Name } from "@nostr-dev-kit/ndk-svelte-components";
	import ndk from "$stores/ndk";
	import { RelativeTime } from "@kind0/ui-common";

    export let event: NDKEvent;
    export let title: string | undefined = undefined;
    export let href: string | undefined = "#";
</script>

<div
    class="card card-compact group"
    on:mouseover
    on:mouseleave
    on:mouseout
>
    <div class="card-body flex flex-col gap-3">
        <div class="card-title justify-between  items-start pb-2">
            <slot name="header" />

            <div class="flex flex-row gap-2 dropdown dropdown-end text-sm font-normal">
                <EventCardDropdownMenu {event} />
                <a {href}>
                    <RelativeTime
                        timestamp={event.created_at*1000}
                        class="text-sm whitespace-nowrap hidden md:block"
                    />
                </a>
            </div>
        </div>


        <slot />
    </div>
</div>

<style lang="postcss">
    :global(.event-card--dropdown-menu) {
        @apply dropdown-content;
        @apply bg-base-100 p-4 rounded-box;
        @apply z-10
    }

    :global(.event-card--dropdown-menu li) {
        @apply py-1;
    }

    :global(.event-card--dropdown-menu li svg) {
        @apply mr-2;
    }
</style>
