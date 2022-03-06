<script>
  import { getContext, onMount } from "svelte";

  export let x;
  export let y;

  const { register, unregister } = getContext("canvas");

  onMount(() => {
    register(draw);

    return () => {
      unregister(draw);
    };
  });

  function draw(ctx) {
    ctx.beginPath();
    ctx.fillStyle = "#f202d2";
    ctx.arc(x, y, 3, 0, 2 * Math.PI, true);
    // ctx.fillRect(x, y, x+5, y+5);
    // ctx.fillRect(0, 0, -300, 300);
    ctx.fill();
  }
</script>
