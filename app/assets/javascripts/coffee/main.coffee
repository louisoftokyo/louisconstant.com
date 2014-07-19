photoNum = 1
locale = "en"
aboutPanelOpen = false
currentAlbum = "general"

$(document).ready -> init()

init = ->
	moveAmount = 10
	zoomAmount = 1.2;
	maxRotation = 20

	$(".menuButton").click ->
		menuSwitch($(@).attr "id")

	$("#thumbnailTable").on 'mouseenter', '.thumbnailCell', ->
		$("img", @).addClass("highlightedThumbnail")

	$("#thumbnailTable").on 'mouseleave', '.thumbnailCell', ->
		$("img", @).css {"transform": "", "-webkit-transform": "", "-ms-transform": ""}
		$("img", @).removeClass("highlightedThumbnail") if not $(@).hasClass "selectedThumbnail"

	$("#thumbnailTable").on 'mousedown', '.thumbnailCell', ->
		$(@).addClass("clickedThumbnail")

	$("#thumbnailTable").on 'mouseup', '.thumbnailCell', ->
		$(@).removeClass("clickedThumbnail")
		$(".imgThumbnail").removeClass("selectedThumbnail")
		$("img", @).addClass("selectedThumbnail")
		getPhoto($("img", @).attr "id")

	$("#thumbnailTable").on 'mousemove', '.thumbnailCell', (e) ->
		xPos = e.pageX - $(@).offset().left - $(@).width()/2
		yPos = e.pageY - $(@).offset().top - $(@).width()/2
		transform = "scale(" + zoomAmount + ", " + zoomAmount + ") perspective(600px) rotateY(" + xPos/100 * maxRotation + "deg) rotateX(" + yPos/100 * -maxRotation + "deg)"
		$("img", @).css {"transform": transform, "-webkit-transform": transform, "-ms-transform": transform}
	
	$("#aboutLabel").click ->
		newHeight = (if aboutPanelOpen then "0" else "165px")
		newPadding = (if aboutPanelOpen then "0" else "120px")
		newBorder = (if aboutPanelOpen then "" else "1px solid white")
		newDottedLineOpacity = (if aboutPanelOpen then "1.0" else "0.0")

		$("#aboutPanel").animate {"padding-top": newPadding, "padding-bottom": newPadding, "height": newHeight}, {duration: 1000, easing: "easeOutQuart", queue: false}
		$("#aboutPanel").css {"border-top": newBorder}
		$(".dottedLine").css {"opacity": newDottedLineOpacity}
		aboutPanelOpen = not aboutPanelOpen

	$(".socialButton").mouseenter ->
		$(@).prev().animate {opacity: "1.0", top: "-10px"}, 100
	$(".socialButton").mouseleave ->
		$(@).prev().animate {opacity: "0.0", top: "0px"}, 100

	$("#mainImg").load ->
		$("#mainImgShadow").width $("#mainImg").width()
		$("#mainImgShadow").height ($("#mainImg").height() * 0.5)
		$("#mainImg").fadeTo 200, 1.0, -> $("#mainImgShadow").fadeTo(200, 1.0)

	$("#rightArrow").click nextPhoto
	$("#leftArrow").click previousPhoto

	getLocale()
	firstPhoto()
	menuSwitch(currentAlbum)

loadPhotoJSON = (photoJSON) ->
	return if photoJSON is null
	$("#mainImgShadow").fadeTo(0, 0.0);
	$("#mainImg").fadeTo 200, 0.0, -> 
		$("#mainImg").attr "src", "/assets/photos/" + currentAlbum + "/" + photoJSON["filename"] + ".jpg"
	$("#imgTitle").fadeTo 200, 0.0, -> 
		$("#imgTitle").html (if locale is "ja" then photoJSON["japanese_title"] else photoJSON["english_title"])
	$("#imgTitle").fadeTo 200, 1.0	
	photoNum = photoJSON["id"]
	$("#mainImgShadow").width $("#mainImg").width() - 4
	$("#mainImgShadow").height ($("#mainImg").height() * 0.6)
	$(".imgThumbnail").removeClass "selectedThumbnail"
	$("#" + photoJSON["filename"]).addClass "selectedThumbnail"

menuSwitch = (menuName) ->
	console.log 'Menu switching to ' + menuName
	$(".menuButton").each -> $(@).removeClass "selected_" + $(@).attr "id"
	selectedMenuObject = $("#" + menuName)
	selectedMenuObject.addClass "selected_" + menuName
	currentAlbum = menuName
	loadThumbnails(menuName)
	firstPhoto(currentAlbum)


loadThumbnails = (album) ->
	console.log 'Loading thumbnails from ' + album
	thumbnailFadeoutTime = 300
	thumbnailFadeoutInterval = 15

	delay = 0;
	$('.imgThumbnail').each -> 
	    $(@).delay(delay)
	    $(@).animate {opacity: 0}, thumbnailFadeoutTime
	    delay += thumbnailFadeoutInterval
		#$(@).attr "src", "/assets/thumbnails/" + currentAlbum + "/" + ($(@).attr "id") + ".jpg"

	$('.imgThumbnail').remove()

	thumbnailsPath = '/assets/thumbnails/' + album + '/'

	imgNames = []
	htmlString = ''

	$.post "home/getAlbum", {albumName:album}, (imgNames) ->
		c = 0
		for imgName in imgNames
			if c is 0
				htmlString += '<tr>'

			htmlString += '<td class="thumbnailCell">'
			htmlString += '<img src="' + thumbnailsPath + imgName + '.jpg" id="' + imgName + '" class="imgThumbnail" width="150px" height="150px"></img>'
			htmlString += '</td>'

			c += 1
			if c is 3
				htmlString += '</tr>'
				c = 0

		loadCounter = 0
		$(".thumbnailImg").load ->
			loadCounter++
		
		$('#thumbnailTable').html(htmlString)

		while(loadCounter < $(".thumbnailImg").length)
			a=0

		delay = 0;
		$('.imgThumbnail').each -> 
	    $(@).delay(delay)
	    $(@).animate {opacity: 0.4}, thumbnailFadeoutTime
	    delay += thumbnailFadeoutInterval




	#$(".imgThumbnail").each -> $(@).attr "src", "/assets/thumbnails/" + currentAlbum + "/" + ($(@).attr "id") + ".jpg"

getLocale          = -> $.get "home/locale"   , {}                                      , (data) -> locale = data
firstPhoto   	   = -> $.get "home/latest"   , {                    album:currentAlbum}, (data) -> loadPhotoJSON data
nextPhoto          = -> $.post "home/next"    , {clientNum:photoNum, album:currentAlbum}, (data) -> loadPhotoJSON data
previousPhoto      = -> $.post "home/previous", {clientNum:photoNum, album:currentAlbum}, (data) -> loadPhotoJSON data
getPhoto = (id)      -> $.post "home/getPhoto", {photoID:id}                            , (data) -> loadPhotoJSON data


