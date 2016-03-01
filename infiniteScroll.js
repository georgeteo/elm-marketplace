function isElementInViewport (el) {
	if (typeof jQuery == "function" && el instanceof jQuery) {
		el = el[0];
	}

	var rect = el.getBoundingClientRect();

	return (F
			rect.top >= 0 &&
			rect.left >= 0 &&
			rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
			rect.right <= (window.innerWidth || document.documentElement.clientWidth)
	);
}

var div = document.getById('content');
var app = Elm.embed(Elm.Main, div, {lastItemVisible : false});

window.onscroll = funcion () {
	var wrapper = document.getElementByClassName("wrapper")[0];
	var lastItem = wrapper.childNodes[wrapper.childNodes.length - 1];

	if (isElementInViewport(lastItem)) {
		app.port.lastItemVisible.send(true);
	}
	else {
		app.port.lastItemVisible.send(false);
	}
};


