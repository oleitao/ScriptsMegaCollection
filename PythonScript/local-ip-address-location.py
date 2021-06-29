#requirements
#pip install geocoder
import geocoder
g = geocoder.ipinfo('me')
print(g.latlng)
