<script lang="ts">
	import {AttentionButton} from "@kind0/ui-common";
    import type { NDKDVMJobResult, NDKEvent } from "@nostr-dev-kit/ndk";
	import { Lightning } from "phosphor-svelte";
    import { requestProvider } from 'webln';

    export let event: NDKDVMJobResult | NDKEvent;


    let amountInMsats: number;
    let invoice: string | null;
    const amountTag = event.getMatchingTags("amount")[0];

    if (amountTag) {
        amountInMsats = parseInt(amountTag[1]);
        invoice = amountTag[2];
    }

    async function pay() {
        console.log('pay')
        if (!amountInMsats) return;

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
            console.log(err);
            return;
        }
    }
</script>

<AttentionButton
    class={$$props.class}
    on:click={pay}
>
    PAY
    <Lightning />
    {#if amountInMsats}
        {amountInMsats/1000} sats
    {/if}
</AttentionButton>
