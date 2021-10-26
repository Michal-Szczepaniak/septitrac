/*

This file is part of Septitrac.
Copyright 2021, Michał Szczepaniak <m.szczepaniak.000@gmail.com>

Septitrac is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Septitrac is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Septitrac. If not, see <http://www.gnu.org/licenses/>.

*/

function formatDuration(value) {
    var text = ""
    var val = value
    if (val >= 86400) text += parseInt(val/86400) + "d "
    val %= 86400
    if (val >= 3600) text += parseInt(val/3600) + "h "
    val %= 3600
    text += parseInt(val/60) + "m"
    return text
}
