using System;
using Microsoft.Dss.Core.Attributes;
using Microsoft.Dss.Core.Transforms;

#if NET_CF20
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"cf.gpsimpl.y2008.m03, version=0.0.0.0, culture=neutral, publickeytoken=00557257f0c3f8b7")]
#else
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"gpsimpl.y2008.m03, version=0.0.0.0, culture=neutral, publickeytoken=00557257f0c3f8b7")]
#endif
#if !URT_MINCLR
[assembly: System.Security.SecurityTransparent]
[assembly: System.Security.AllowPartiallyTrustedCallers]
#endif

namespace Dss.Transforms.TransformGPSImpl
{

    public class Transforms: TransformBase
    {
        static Transforms()
        {
            Register();
        }
        public static void Register()
        {
        }
    }
}

