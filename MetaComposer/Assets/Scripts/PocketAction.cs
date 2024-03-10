using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json;
namespace MetaComposer.Assets
{
    public struct PocketAction
    {
        [JsonProperty("type")]
        public string Type;
        [JsonProperty("payload")]
        public string Payload;
    }

}
