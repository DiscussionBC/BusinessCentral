Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ReadyVoice", "");
var SpeechRecognition = SpeechRecognition || webkitSpeechRecognition;
var recognition = new SpeechRecognition();
recognition.continuous = false;
recognition.lang = 'es-ES';
recognition.interimResults = false;
recognition.maxAlternatives = 1;
recognition.onspeechend = function() {
// when user is done speaking
recognition.stop();
};

recognition.onresult = function(event) {
try {
var transcript = event.results[0][0].transcript;
var confidence = event.results[0][0].confidence;
Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("voice",[transcript]);
} catch (err) {
console.log(err);
};
};

function speak(listenTxt){
try {
const utterThis = new SpeechSynthesisUtterance(listenTxt);
utterThis.lang = 'es-ES';
utterThis.pitch = 1;
utterThis.rate = 1;
window.speechSynthesis.speak(utterThis);
} catch (err) {
console.log(err);
};
};

function stoprecording(){
recognition.abort();
};
function startrecording(){
recognition.start();
};