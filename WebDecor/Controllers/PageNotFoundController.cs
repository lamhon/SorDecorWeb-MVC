﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace WebDecor.Controllers
{
    public class PageNotFoundController : Controller
    {
        // GET: PageNotFound
        public ActionResult Index()
        {
            return View();
        }
    }
}