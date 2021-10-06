﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FamiStudio
{
    public static class DpiScaling
    {
        private static bool initialized; 

        private static float mainWindowScaling = 1;
        private static float fontScaling = 1;
        private static float dialogScaling = 1;

        public static float MainWindow { get { Debug.Assert(initialized); return mainWindowScaling; } }
        public static float Font       { get { Debug.Assert(initialized); return fontScaling; } }
        public static float Dialog     { get { Debug.Assert(initialized); return dialogScaling; } }

        public static int ScaleCustom(float val, float scale)
        {
            Debug.Assert(initialized);
            return (int)Math.Round(scale * mainWindowScaling);
        }

        public static float ScaleCustomFloat(float val, float scale)
        {
            Debug.Assert(initialized);
            return scale * mainWindowScaling;
        }

        public static int ScaleForMainWindow(float val)
        {
            Debug.Assert(initialized);
            return (int)Math.Round(val * mainWindowScaling);
        }

        public static float ScaleForMainWindowFloat(float val)
        {
            Debug.Assert(initialized);
            return val * mainWindowScaling;
        }

        public static int ScaleForDialog(float val)
        {
            Debug.Assert(initialized);
            return (int)Math.Round(val * dialogScaling);
        }

        public static int[] GetAvailableScalings()
        {
            if (PlatformUtils.IsWindows || PlatformUtils.IsLinux)
                return new[] { 100, 150, 200 };
            else if (PlatformUtils.IsMacOS)
                return new[] { 100, 200 };
            else if (PlatformUtils.IsAndroid)
                return new[] { 66, 100, 133 };

            Debug.Assert(false);
            return new int[] { };
        }

        public static void Initialize()
        {
            dialogScaling = PlatformUtils.GetDesktopScaling();

            if (Settings.DpiScaling != 0)
                mainWindowScaling = Settings.DpiScaling / 100.0f;
            else
                mainWindowScaling = dialogScaling;

            if (PlatformUtils.IsAndroid)
            {
                fontScaling       = (float)Math.Round(mainWindowScaling * 3);
                mainWindowScaling = (float)Math.Round(mainWindowScaling * 6);
            }
            else
            {
                mainWindowScaling = Math.Min(2.0f, (int)(dialogScaling * 2.0f) / 2.0f); // Round to 1/2 (so only 100%, 150% and 200%) are supported.
                fontScaling = mainWindowScaling;
            }

            initialized = true;
        }
    }
}
