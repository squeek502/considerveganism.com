//= require_tree .

/* from https://github.com/pinceladasdaweb/Frontend-Snippets/tree/master/JS/Pure-JavaScript-hasClass-addClass-removeClass-toggleClass */
Element.prototype.hasClass = function (className) {
	return new RegExp(' ' + className + ' ').test(' ' + this.className + ' ');
};

Element.prototype.addClass = function (className) {
	if (!this.hasClass(className)) {
		this.className += ' ' + className;
	}
	return this;
};

Element.prototype.removeClass = function (className) {
	var newClass = ' ' + this.className.replace(/[\t\r\n]/g, ' ') + ' ';
	if (this.hasClass(className)) {
		while (newClass.indexOf( ' ' + className + ' ') >= 0) {
			newClass = newClass.replace(' ' + className + ' ', ' ');
		}
		this.className = newClass.replace(/^\s+|\s+$/g, ' ');
	}
	return this;
};

Element.prototype.toggleClass = function (className) {
	var newClass = ' ' + this.className.replace(/[\t\r\n]/g, " ") + ' ';
	if (this.hasClass(className)) {
		while (newClass.indexOf(" " + className + " ") >= 0) {
			newClass = newClass.replace(" " + className + " ", " ");
		}
		this.className = newClass.replace(/^\s+|\s+$/g, ' ');
	} else {
		this.className += ' ' + className;
	}
	return this;
};

function clamp(num, min, max) {
	return Math.min(Math.max(num, min), max);
};

function isElementWithinViewport(el) {
	var top = el.offsetTop;
	var left = el.offsetLeft;
	var width = el.offsetWidth;
	var height = el.offsetHeight;

	while(el.offsetParent) {
		el = el.offsetParent;
		top += el.offsetTop;
		left += el.offsetLeft;
	}

	return (
		top < (window.pageYOffset + window.innerHeight) &&
		left < (window.pageXOffset + window.innerWidth) &&
		(top + height) > window.pageYOffset &&
		(left + width) > window.pageXOffset
	);
}

// TODO: Finish this
function findAndRaiseCurrentSection() {
	var scrollCurrent = (document.documentElement && document.documentElement.scrollTop) || document.body.scrollTop;
	var windowHeight = window.innerHeight;
	var sections = document.getElementsByClassName("section-container")
	var sections = Array.prototype.filter.call(sections, function(el) {
		return isElementWithinViewport(el);
	})

	for (var i=0; i<sections.length; i++) {
		var el = sections[i]
	}
}

function ready() {
	var stickyHeader = document.getElementById("sticky-header"),
		stickyHeaderHeight = stickyHeader.offsetHeight,
		scrollLast = 0;

	function scroll(event) {
		findAndRaiseCurrentSection();

		stickyHeaderHeight = stickyHeader.offsetHeight;

		stickyHeader.addClass("stick")
		document.body.style.marginTop = stickyHeaderHeight + 'px'

		var scrollCurrent = (document.documentElement && document.documentElement.scrollTop) || document.body.scrollTop;
		var scrollDiff = scrollCurrent - scrollLast;
		var documentHeight = document.body.offsetHeight;
		var windowHeight = window.innerHeight;
		var newStickyHeaderTop = parseInt( window.getComputedStyle(stickyHeader).getPropertyValue('top') ) - scrollDiff;
		var sectionHeaderOffset = 0;

		if (scrollCurrent <= 0) // scrolled to the very top; element sticks to the top
		{
			sectionHeaderOffset = stickyHeaderHeight;
			stickyHeader.style.top = '0px'
		}
		else if (scrollDiff < 0) // scrolled up; element slides in
		{
			sectionHeaderOffset = newStickyHeaderTop > 0 ? stickyHeaderHeight : newStickyHeaderTop + stickyHeaderHeight
			stickyHeader.style.top = (sectionHeaderOffset - stickyHeaderHeight) + 'px';
		}
		else if (scrollDiff > 0) // scrolled down
		{
			if (scrollCurrent + windowHeight >= documentHeight - stickyHeaderHeight) // scrolled to the very bottom; element slides in
			{
				var heightLeftToScroll = scrollCurrent + windowHeight - documentHeight
				sectionHeaderOffset = heightLeftToScroll < 0 ? heightLeftToScroll + stickyHeaderHeight : stickyHeaderHeight
				stickyHeader.style.top = (sectionHeaderOffset - stickyHeaderHeight) + 'px'
			}
			else // scrolled down; element slides out
			{
				sectionHeaderOffset = Math.abs( newStickyHeaderTop ) > stickyHeaderHeight ? 0 : newStickyHeaderTop + stickyHeaderHeight
				stickyHeader.style.top = (sectionHeaderOffset - stickyHeaderHeight) + 'px';
			}
		}

		var sections = document.getElementsByClassName("section-container")

		for (var i=0; i<sections.length; i++) {
			var el = sections[i]
			var headers = el.getElementsByClassName("section-header")
			var header = headers.length > 0 ? headers[0] : null;

			if (header === null)
				continue;

			var percentScrolled = (scrollCurrent - el.offsetTop + sectionHeaderOffset) / el.offsetHeight;
			percentScrolled = clamp(percentScrolled, 0.0, 1.0);
			var topOffset = percentScrolled * el.offsetHeight;

			if (topOffset + header.offsetWidth >= el.offsetHeight) {
				header.style.top = (el.offsetHeight - header.offsetWidth) + 'px'
			} else {
				header.style.top = topOffset + 'px'
			}
		}

		scrollLast = scrollCurrent;
	}

	window.addEventListener('scroll', scroll);
	window.addEventListener('resize', scroll);
}

if (document.readyState == 'complete' || document.readyState == 'loaded') {
	ready();
} else {
	window.addEventListener('DOMContentLoaded', ready);
}