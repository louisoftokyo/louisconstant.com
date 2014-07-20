locale = "en"

photoNum = 1
currentAlbum = "general"

$(document).ready -> init()

init = ->
	moveAmount = 10
	zoomAmount = 1.2;
	maxRotation = 60

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
		open = $("#aboutPanel").hasClass("open")
		oldClass = (if open then "open" else "closed")
		newClass = (if open then "closed" else "open")
		$("#aboutPanel").switchClass(oldClass, newClass, {'duration': 1000, 'easing': 'easeOutQuart'});
		$(".dottedLine").css {"opacity": (if open then "1.0" else "0.0")}

	$(".socialButton").mouseenter ->
		$(@).prev().animate {opacity: "1.0", top: "-10px"}, 100
	$(".socialButton").mouseleave ->
		$(@).prev().animate {opacity: "0.0", top: "0px"}, 100

	$("#mainImg").load ->
		$("#mainImgShadow").width $("#mainImg").width()
		$("#mainImgShadow").height ($("#mainImg").height() * 0.5)

		$("#mainImgBacking").width $("#mainImg").width()
		$("#mainImgBacking").height ($("#mainImg").height())

		$("#mainImg, #mainImgShadow").fadeTo 200, 1.0

	$("#rightArrow").click nextPhoto
	$("#leftArrow").click previousPhoto

	getLocale()
	firstPhoto()
	menuSwitch(currentAlbum)

loadPhotoJSON = (photoJSON) ->
	return if photoJSON is null
	$("#mainImg, #mainImgShadow").fadeTo 200, 0.0, -> 
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
	$(".menuButton").each -> $(@).removeClass "selected_" + $(@).attr "id"
	selectedMenuObject = $("#" + menuName)
	selectedMenuObject.addClass "selected_" + menuName
	currentAlbum = menuName
	loadThumbnails(menuName)
	firstPhoto(currentAlbum)


loadThumbnails = (album) ->
	thumbnailFadeoutTime = 350
	thumbnailFadeoutInterval = 20

	delay = 0;
	$('.thumbnailCell').each -> 
	    $(@).delay $(@).index() * thumbnailFadeoutInterval
	    $(@).animate {opacity: 0}, thumbnailFadeoutTime

	$('.thumbnailRow').remove()

	thumbnailsPath = '/assets/thumbnails/' + album + '/'

	imgNames = []
	htmlString = ''

	$.post "home/getAlbum", {albumName:album}, (imgNames) ->
		loadCounter = 0
		c = 0
		tr = $('<tr>', {class: 'thumbnailRow'})
		count = 0
		for imgName in imgNames
			img = $('<img>', {id: imgName, class: 'imgThumbnail', src: thumbnailsPath + imgName + '.jpg'})

			img.load ->
				loadCounter += 1
				if loadCounter is imgNames.length
					delay = 0;
					$('.imgThumbnail').each -> 
					    $(@).delay(delay)
					    $(@).animate {opacity: 0.4}, thumbnailFadeoutTime
					    delay += thumbnailFadeoutInterval

			td = $('<td>', {class: 'thumbnailCell'})
			td.append img

			tr.append td

			c += 1
			if c == 3
				c = 0
				$('#thumbnailTable').append tr
				tr = $('<tr>', {class: 'thumbnailRow'})

			if count + 1 is imgNames.length
				$('#thumbnailTable').append tr

			count += 1

getLocale          = -> $.get "home/locale"   , {}                                      , (data) -> locale = data
firstPhoto   	   = -> $.get "home/latest"   , {                    album:currentAlbum}, (data) -> loadPhotoJSON data
nextPhoto          = -> $.post "home/next"    , {clientNum:photoNum, album:currentAlbum}, (data) -> loadPhotoJSON data
previousPhoto      = -> $.post "home/previous", {clientNum:photoNum, album:currentAlbum}, (data) -> loadPhotoJSON data
getPhoto = (id)      -> $.post "home/getPhoto", {photoID:id}                            , (data) -> loadPhotoJSON data
log = (s)		     -> console.log s


