﻿// /*----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------*/

using System;
using System.Linq;

namespace onesharp
{

    class MainClass
    {

        public static void Main(string[] args)
        {
            var app = new webserver();
            app.АргументыКоманднойСтроки = args;
            app.Main();
        }
    }
}
