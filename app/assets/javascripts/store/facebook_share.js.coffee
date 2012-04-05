$ = jQuery
postToFeed = (link, options = {})->
  default_obj =
    method: 'feed'
    link: link
  obj = $.extend(default_obj, options)

  callback = () ->
    document.getElementById('msg').innerHTML = "Post ID: " + response['post_id']

  FB.ui(obj, callback)

sendToFBFriends = (link, message = 'Join Sold.sg') ->
  obj =
    method: 'send'
    link: link
    name: message
  callback = () ->
    alert('message had been sent')
  FB.ui(obj, callback)

window.postToFeed = postToFeed
window.sendToFBFriends = sendToFBFriends