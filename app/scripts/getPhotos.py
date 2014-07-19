from __future__ import unicode_literals

import flickrapi
import sys
import codecs
import sqlite3
import urllib
import os
import getColours

dbDev = 'development.sqlite3'
dbLive = 'live.sqlite3'

homePath = 'd:/dev/photos'

db = sqlite3.connect(os.path.join(homePath, 'db', dbDev))
apiKey = '4f85c2767954baab84d30074927e52db'
apiSecret = 'ca21182c305e6173'
username = '95043389@N04'    
flickr = flickrapi.FlickrAPI(apiKey, apiSecret)

photosPath = os.path.join(homePath, 'app/assets/images/photos/{0}/{1}.jpg')
thumbnailsPath = os.path.join(homePath, 'app/assets/images/thumbnails/{0}/{1}.jpg')

def downloadPhoto(url, id, thumbnail, album):
  path = ''
  if(thumbnail == False):
    path = photosPath.format(album, id)
    print 'Downloading thumbnail ', id, 'into album folder', album, '...'
  else:
    path = thumbnailsPath.format(album, id)
    print '##############', photosPath
    print 'Downloading photo ', id, 'into album folder', album, '...'

  gotPhoto = False
  while not gotPhoto:
    try:
      urllib.urlretrieve(url, path)
      print 'Success.'
      gotPhoto = True
    except Exception as e:
      print 'Failed to get photo:', e
      print 'Retrying...'

def getPhotoData():
  album_General   = 'general'  , '72157645072004150'
  album_People    = 'people'   , '72157645677521876'
  album_Events    = 'events'   , ''
  album_Interiors = 'interiors', ''

  traverseAlbum(album_General)
  traverseAlbum(album_People)
  #traverseAlbum(album_Events)
  #traverseAlbum(album_Interiors)

def traverseAlbum(album):
  count = 1
  numToSkip = 0

  print 'Traversing album: ', album

  for photo in flickr.walk_set(photoset_id=album[1], extras='url_h'):
    if count < numToSkip + 1:
      count += 1
      continue

    title = photo.get('title')
    id    = photo.get('id')

    print 'Processing photo #', count, ':', title

    if not os.path.isfile(photosPath.format(album[0], id)):
      try:
        url = photo.attrib['url_h']
        downloadPhoto(url, id, False, album[0])
      except Exception, e:
        print 'Full-size photo failure:', e
    else:
      print 'Already got photo', id, '- skipping'   
      
    if not os.path.isfile(thumbnailsPath.format(album[0], id)):
      url = "http://farm%s.staticflickr.com/%s/%s_%s_q.jpg" % (photo.attrib['farm'], photo.attrib['server'], id, photo.attrib['secret'])
      downloadPhoto(url, id, True, album[0])
    else:
      print 'Already got thumbnail', id, 'in album', album[0], '- skipping'

    info = flickr.photos_getInfo(photo_id=id) 

    #Forget colours for now
    hue, brightness = [0, 0] #getColours.getHue(photosPath % id)       

    description = unicode(info.find('photo').find('description').text)    
    exifResponse = flickr.photos_getExif(photo_id=id);
    
    shutter_speed = ""
    f = ""
    iso = ""
    focal_length = ""
    date_taken = ""
    
    for datum in exifResponse.find('photo'):
      if datum.attrib["label"] == "Exposure":
        shutter_speed = datum.find('raw').text
      if datum.attrib["label"] == "Aperture":
        f = datum.find('raw').text
      if datum.attrib["label"] == "ISO Speed":
        iso = datum.find('raw').text
      if datum.attrib["label"] == "Focal Length (35mm format)":
        focal_length = datum.find('raw').text     
      if datum.attrib["label"] == "Date and Time (Original)":
        date_taken = datum.find('raw').text
    
    focal_length = focal_length.replace(' mm', '')
    date_taken = date_taken.replace(':', '-', 2)
    
    photoData = {'id': id, 'album': album[0], 'english_title': title, 'japanese_title': description}
    
    insertPhotoData(db, photoData)

    count += 1

    
def insertPhotoData(db, photoData):
  sqlIF = """SELECT filename FROM photos WHERE filename = ? AND album = ?"""
  sqlUPDATE = """UPDATE photos
                 SET album = ?, english_title=?, japanese_title=?
                 WHERE filename = ?"""
  sqlINSERT = """INSERT INTO photos (filename, english_title, japanese_title, album)
                  VALUES (?, ?, ?, ?)"""
 
  with db:
      
    cur = db.execute(sqlIF, (photoData['id'], photoData['album']))
    alreadyExists = cur.fetchone() is not None
    
    if alreadyExists:
      db.execute(sqlUPDATE, (photoData['album'], photoData['english_title'], photoData['japanese_title'], photoData['id']))
      print 'Updated', photoData['id'], '(' + photoData['english_title'] + ').'
    else:
      db.execute(sqlINSERT, (photoData['id'], photoData['english_title'], photoData['japanese_title'], photoData['album']))
      print 'Inserted', photoData['id'], '(' + photoData['english_title'] + ').'

def main():
  getPhotoData()

if __name__ == "__main__":
  main()