var instance

function console_log_ex(location, size) {
    var buffer = new Uint8Array(
        instance.exports.memory.buffer,
        location,
        size
    )
    var decoder = new TextDecoder()
    var string = decoder.decode(buffer)
    console.log(string)
}
var imports = {
    env: {
        console_log_ex: console_log_ex,
    },
}
export default async function init() {
    let response = await fetch('lib.wasm')
    let bytes = await response.arrayBuffer()
    instance = (await WebAssembly.instantiate(bytes, imports)).instance
    return instance.exports
}
