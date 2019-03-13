/*
* Copyright (c) 2018-2019 Dirli <litandrej85@gmail.com>
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*/

namespace WeatherApplet {
    public class WeatherInfo : Object {
        public string city_name {get; set;}
        public string humidity {get; set;}
        public string icon_name {get; set;}
        public string l_update_t {get; set;}
        public string description {get; set;}
        public string sunrise {get; set;}
        public string sunset {get; set;}
        public string temp {get; set;}
        public string wind {get; set;}
    }
}
