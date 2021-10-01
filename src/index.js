import { Elm } from './Main.elm';

const app = Elm.Main.init({});

app.ports.highlight.subscribe(function() {
    requestAnimationFrame(function() {
        const block = document.getElementById('code');
        hljs.highlightElement(block);
    });
});