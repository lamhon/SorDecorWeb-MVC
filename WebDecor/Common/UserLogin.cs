﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebDecor.Common
{
    [Serializable]
    public class UserLogin
    {
        public string userName { get; set; }
        public string userID { get; set; }
    }
}