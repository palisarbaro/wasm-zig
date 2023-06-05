import { drawBuff, getBuff, initCanvas } from './canvas.js'
import init from './wasm.js'
let wasm = await init()
let {canvas, ctx} = initCanvas('app')


const size = 100
const screenLoc = wasm.initBoard(size, size)
const buff = getBuff(wasm, screenLoc, size)
console.log(buff)

async function delay() {
    return new Promise((resolve) => setTimeout(resolve, 10))
}
async function render() {
    let start = new Date()
        wasm.render()
        wasm.tick()
    console.log(new Date() - start);
    
    drawBuff(canvas, buff)
    await delay()
    requestAnimationFrame(render)
}
render()
