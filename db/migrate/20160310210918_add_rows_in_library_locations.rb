class AddRowsInLibraryLocations < ActiveRecord::Migration
  def change
  locations = { "Albany Park" => 60625, "Altgeld" => 60827, "Archer Heights" => 60632,
                "Austin" => 60644, "Austin-Irving" => 60634, "Avalon" => 60617, 
                "Back of the Yards" => 60609, "Beverly" => 60643, "Bezazian" => 60640,
                "Blackstone" => 60615, "Brainerd" => 60620, "Brighton Park" => 60632,
                "Bucktown-Wicker Park" => 60647, "Budlong Woods" => 60659, "Canaryville" => 60609,
                "Chicago Bee" => 60609, "Chicago Lawn" => 60629, "Chinatown" => 60616,
                "Clearing" => 60638, "Coleman" => 60637, "Daley, Richard J.-Bridgeport" => 60608,
                "Daley, Richard M.-W Humboldt" => 60612, "Douglass" => 60623, "Dunning" => 60634,
                "Edgebrook" => 60646, "Edgewater" => 60660, "Gage Park" => 60632, "Galewood-Mont Clare" => 60707,
                "Garfield Ridge" => 60638, "Greater Grand Crossing" => 60619, "Hall" => 60615,
                "Harold Washington" => 60605, "Hegewisch" => 60633, "Humboldt Park" => 60647,
                "Independence" => 60618, "Jefferson Park" => 60630, "Jeffery Manor" => 60617,
                "Kelly" => 60621, "King" => 60616, "Legler" => 60624, "Lincoln Belmont" => 60657,
                "Lincoln Park" => 60614, "Little Village" => 60623, "Logan Square" => 60647,
                "Lozano" => 60608, "Manning" => 60612, "Mayfair" => 60630, "McKinley Park" => 60609,
                "Merlo" => 60657, "Mount Greenwood" => 60655, "Near North" => 60610, "North Austin" => 60639,
                "North Pulaski" => 60639, "Northtown" => 60645, "Oriole Park" => 60656, "Portage-Cragin" => 60641,
                "Pullman" => 60628, "Roden" => 60631, "Rogers Park" => 60626, "Roosevelt" => 60607,
                "Scottsdale" => 60652, "Sherman Park" => 60609, "South Chicago" => 60617,
                "South Shore" => 60649, "Sulzer Regional" => 60625, "Thurgood Marshall" => 60620,
                "Toman" => 60623, "Uptown" => 60613, "Vodak-East Side" => 60617, "Walker" => 60643,
                "Water Works" => 60611, "West Belmont" => 60634, "West Chicago Avenue" => 60651,
                "West Englewood" => 60636, "West Lawn" => 60629, "West Pullman" => 60643,
                "West Town" => 60622, "Whitney M. Young, Jr." => 60619, "Woodson Regional" => 60628,
                "Wrightwood-Ashburn" => 60652 }

    locations.each do |name, zipcode|
      LibraryLocation.create(name: name, zipcode: zipcode)
    end
  end
end
