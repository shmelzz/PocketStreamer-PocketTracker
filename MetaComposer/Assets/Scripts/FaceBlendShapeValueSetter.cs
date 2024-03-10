using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;
using UnityEngine;
using VRM;
using UnityRandom = UnityEngine.Random;


namespace MetaComposer.Assets
{
    public class FaceBlendShapeValueSetter
    {
        public static string[] BLEND_SHAPES_NAMES;

        static FaceBlendShapeValueSetter()
        {
            PropertyInfo[] properties = typeof(FaceTrackingData).GetProperties();
            BLEND_SHAPES_NAMES = properties.Select(p => p.Name).Where(name => name != "timeCode").ToArray();
        }

        public static Dictionary<BlendShapeKey, float> ToBlendShapeDictionary(FaceTrackingData data)
        {
            Dictionary<BlendShapeKey, float> blendShapeDictionary = BLEND_SHAPES_NAMES
                .ToDictionary(name => BlendShapeKey.CreateUnknown(name),
                              name =>
                              {
                                  PropertyInfo propertyInfo = data.GetType().GetProperty(name);
                                  if (propertyInfo != null)
                                  {
                                      return Convert.ToSingle(propertyInfo.GetValue(data));
                                  }
                                  else
                                  {
                                      // TODO: Handle the case where the property does not exist.
                                      return 0.0f;
                                  }
                              });
            return blendShapeDictionary;
        }
    }
}