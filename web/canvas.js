
export function initCanvas(id){
    let canvas = document.getElementById(id)
    let ctx = canvas.getContext('2d')
    ctx.imageSmoothingEnabled = false
    return {canvas, ctx}
}

export function getBuff(wasm, location, size){
    const buff = new Uint8ClampedArray(wasm.memory.buffer, location, size * size*4)
    return buff;
}

export async function drawBuff(canvas, buff) {
    let ctx = canvas.getContext('2d')
    let size = Math.floor(Math.sqrt(buff.length/4))
    let u8 = new Uint8ClampedArray(buff)
    let imageData = new ImageData(u8, size)
    let imagebitmap = await createImageBitmap(imageData)
    ctx.drawImage(imagebitmap, 0, 0, canvas.width, canvas.height)
}