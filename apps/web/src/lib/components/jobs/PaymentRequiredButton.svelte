<script lang="ts">
	import {AttentionButton} from "@kind0/ui-common";
    import type { NDKDVMJobResult, NDKEvent } from "@nostr-dev-kit/ndk";
	import { Lightning } from "phosphor-svelte";
	import { slide } from "svelte/transition";
    import { requestProvider } from 'webln';

    export let event: NDKDVMJobResult | NDKEvent;


    let amountInMsats: number;
    let invoice: string | null;
    const amountTag = event.getMatchingTags("amount")[0];

    let paying = false;
    let error: string | undefined = undefined;

    if (amountTag) {
        amountInMsats = parseInt(amountTag[1]);
        invoice = amountTag[2];
    }

    async function pay() {
        if (!amountInMsats) return;

        paying = true;

        try {
            if (!invoice) {
                invoice = await event.zap(parseInt(amountInMsats));
            }

            const webln = await requestProvider();
            await webln.sendPayment(invoice!);
            // TODO we should check here if the payment was successful, with a timer
            // that is canceled here; if the timer doesn't come back, show the modal again
            // or instruct the user to do something with the failed payment
        } catch (err: any) {
            error = err.message ?? err;
            setTimeout(() => {
                error = undefined
            }, 5000);
            paying = false;
            console.log(err);
            return;
        }
    }
</script>

{#if error}
    <div class="toast toast-end" transition:slide>
        <div class="alert alert-error">
            <span>{error}</span>
        </div>
    </div>
{/if}

<div class="flex flex-col gap-2">
    <AttentionButton class="
        w-full flex-nowrap whitespace-nowrap
        {$$props.class??""}
    " on:click={pay}>
        {#if paying}
            <span class="loading loading-sm"></span>
        {:else}
            PAY
        {/if}
        <Lightning />
        {#if amountInMsats}
            {amountInMsats/1000} sats
        {/if}
    </AttentionButton>

</div>