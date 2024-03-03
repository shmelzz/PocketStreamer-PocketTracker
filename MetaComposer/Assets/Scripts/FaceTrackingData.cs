using Newtonsoft.Json;
using UnityRandom = UnityEngine.Random;

namespace MetaComposer.Assets
{
    public class FaceTrackingData
    {
        [JsonProperty("timeCode")]
        public double timeCode { get; set; }

        [JsonProperty("browDown_L")]
        public double BrowDownLeft { get; set; }

        [JsonProperty("browDown_R")]
        public double BrowDownRight { get; set; }

        [JsonProperty("browInnerUp")]
        public double BrowInnerUp { get; set; }

        [JsonProperty("browOuterUp_L")]
        public double BrowOuterUpLeft { get; set; }

        [JsonProperty("browOuterUp_R")]
        public double BrowOuterUpRight { get; set; }

        [JsonProperty("cheekPuff")]
        public double CheekPuff { get; set; }

        [JsonProperty("cheekSquint_L")]
        public double CheekSquintLeft { get; set; }

        [JsonProperty("cheekSquint_R")]
        public double CheekSquintRight { get; set; }

        [JsonProperty("eyeBlink_L")]
        public double EyeBlinkLeft { get; set; }

        [JsonProperty("eyeBlink_R")]
        public double EyeBlinkRight { get; set; }

        [JsonProperty("eyeLookDown_L")]
        public double EyeLookDownLeft { get; set; }

        [JsonProperty("eyeLookDown_R")]
        public double EyeLookDownRight { get; set; }

        [JsonProperty("eyeLookIn_L")]
        public double EyeLookInLeft { get; set; }

        [JsonProperty("eyeLookIn_R")]
        public double EyeLookInRight { get; set; }

        [JsonProperty("eyeLookOut_L")]
        public double EyeLookOutLeft { get; set; }

        [JsonProperty("eyeLookOut_R")]
        public double EyeLookOutRight { get; set; }

        [JsonProperty("eyeLookUp_L")]
        public double EyeLookUpLeft { get; set; }

        [JsonProperty("eyeLookUp_R")]
        public double EyeLookUpRight { get; set; }

        [JsonProperty("eyeSquint_L")]
        public double EyeSquintLeft { get; set; }

        [JsonProperty("eyeSquint_R")]
        public double EyeSquintRight { get; set; }

        [JsonProperty("eyeWide_L")]
        public double EyeWideLeft { get; set; }

        [JsonProperty("eyeWide_R")]
        public double EyeWideRight { get; set; }

        [JsonProperty("jawForward")]
        public double JawForward { get; set; }

        [JsonProperty("jawLeft")]
        public double JawLeft { get; set; }

        [JsonProperty("jawOpen")]
        public double JawOpen { get; set; }

        [JsonProperty("jawRight")]
        public double JawRight { get; set; }

        [JsonProperty("mouthClose")]
        public double MouthClose { get; set; }

        [JsonProperty("mouthDimple_L")]
        public double MouthDimpleLeft { get; set; }

        [JsonProperty("mouthDimple_R")]
        public double MouthDimpleRight { get; set; }

        [JsonProperty("mouthFrown_L")]
        public double MouthFrownLeft { get; set; }

        [JsonProperty("mouthFrown_R")]
        public double MouthFrownRight { get; set; }

        [JsonProperty("mouthFunnel")]
        public double MouthFunnel { get; set; }

        [JsonProperty("mouthLeft")]
        public double MouthLeft { get; set; }

        [JsonProperty("mouthLowerDown_L")]
        public double MouthLowerDownLeft { get; set; }

        [JsonProperty("mouthLowerDown_R")]
        public double MouthLowerDownRight { get; set; }

        [JsonProperty("mouthPress_L")]
        public double MouthPressLeft { get; set; }

        [JsonProperty("mouthPress_R")]
        public double MouthPressRight { get; set; }

        [JsonProperty("mouthPucker")]
        public double MouthPucker { get; set; }

        [JsonProperty("mouthRight")]
        public double MouthRight { get; set; }

        [JsonProperty("mouthRollLower")]
        public double MouthRollLower { get; set; }

        [JsonProperty("mouthRollUpper")]
        public double MouthRollUpper { get; set; }

        [JsonProperty("mouthShrugLower")]
        public double MouthShrugLower { get; set; }

        [JsonProperty("mouthShrugUpper")]
        public double MouthShrugUpper { get; set; }

        [JsonProperty("mouthSmile_L")]
        public double MouthSmileLeft { get; set; }

        [JsonProperty("mouthSmile_R")]
        public double MouthSmileRight { get; set; }

        [JsonProperty("mouthStretch_L")]
        public double MouthStretchLeft { get; set; }

        [JsonProperty("mouthStretch_R")]
        public double MouthStretchRight { get; set; }

        [JsonProperty("mouthUpperUp_L")]
        public double MouthUpperUpLeft { get; set; }

        [JsonProperty("mouthUpperUp_R")]
        public double MouthUpperUpRight { get; set; }

        [JsonProperty("noseSneer_L")]
        public double NoseSneerLeft { get; set; }

        [JsonProperty("noseSneer_R")]
        public double NoseSneerRight { get; set; }

        [JsonProperty("tongueOut")]
        public double TongueOut { get; set; }
        public static FaceTrackingData GenerateRandomFaceTrackingData()
        {
            // Generate a new instance of FaceTrackingData
            FaceTrackingData faceTrackingData = new FaceTrackingData
            {
                timeCode = UnityRandom.Range(0f, 1f),
                MouthStretchRight = UnityRandom.Range(0f, 1f),
                MouthRollUpper = UnityRandom.Range(0f, 1f),
                BrowOuterUpRight = UnityRandom.Range(0f, 1f),
                EyeLookUpLeft = UnityRandom.Range(0f, 1f),
                EyeSquintRight = UnityRandom.Range(0f, 1f),
                MouthLeft = UnityRandom.Range(0f, 1f),
                BrowDownRight = UnityRandom.Range(0f, 1f),
                MouthFrownRight = UnityRandom.Range(0f, 1f),
                EyeBlinkRight = UnityRandom.Range(0f, 1f),
                MouthFrownLeft = UnityRandom.Range(0f, 1f),
                EyeLookDownRight = UnityRandom.Range(0f, 1f),
                EyeSquintLeft = UnityRandom.Range(0f, 1f),
                EyeLookOutLeft = UnityRandom.Range(0f, 1f),
                JawForward = UnityRandom.Range(0f, 1f),
                MouthRollLower = UnityRandom.Range(0f, 1f),
                MouthDimpleLeft = UnityRandom.Range(0f, 1f),
                MouthSmileLeft = UnityRandom.Range(0f, 1f),
                EyeWideLeft = UnityRandom.Range(0f, 1f),
                BrowOuterUpLeft = UnityRandom.Range(0f, 1f),
                EyeLookUpRight = UnityRandom.Range(0f, 1f),
                MouthShrugLower = UnityRandom.Range(0f, 1f),
                BrowInnerUp = UnityRandom.Range(0f, 1f),
                MouthUpperUpRight = UnityRandom.Range(0f, 1f),
                MouthClose = UnityRandom.Range(0f, 1f),
                JawLeft = UnityRandom.Range(0f, 1f),
                MouthStretchLeft = UnityRandom.Range(0f, 1f),
                JawRight = UnityRandom.Range(0f, 1f),
                JawOpen = UnityRandom.Range(0f, 1f),
                CheekSquintRight = UnityRandom.Range(0f, 1f),
                EyeLookInLeft = UnityRandom.Range(0f, 1f),
                MouthDimpleRight = UnityRandom.Range(0f, 1f),
                MouthPucker = UnityRandom.Range(0f, 1f),
                BrowDownLeft = UnityRandom.Range(0f, 1f),
                MouthLowerDownLeft = UnityRandom.Range(0f, 1f),
                MouthUpperUpLeft = UnityRandom.Range(0f, 1f),
                NoseSneerRight = UnityRandom.Range(0f, 1f),
                EyeLookDownLeft = UnityRandom.Range(0f, 1f),
                MouthRight = UnityRandom.Range(0f, 1f),
                MouthPressRight = UnityRandom.Range(0f, 1f),
                MouthPressLeft = UnityRandom.Range(0f, 1f),
                CheekPuff = UnityRandom.Range(0f, 1f),
                CheekSquintLeft = UnityRandom.Range(0f, 1f),
                EyeLookInRight = UnityRandom.Range(0f, 1f),
                MouthSmileRight = UnityRandom.Range(0f, 1f),
                MouthShrugUpper = UnityRandom.Range(0f, 1f),
                EyeBlinkLeft = UnityRandom.Range(0f, 1f),
                MouthFunnel = UnityRandom.Range(0f, 1f),
                NoseSneerLeft = UnityRandom.Range(0f, 1f),
                MouthLowerDownRight = UnityRandom.Range(0f, 1f),
                EyeLookOutRight = UnityRandom.Range(0f, 1f),
                EyeWideRight = UnityRandom.Range(0f, 1f),
                TongueOut = UnityRandom.Range(0f, 1f)
            };

            return faceTrackingData;
        }
    }
}