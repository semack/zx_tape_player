import 'definitions.dart';
import 'extensions.dart';

String fixScreenShotUrl(String url)
{
  if (url.startsWith('/zxscreens'))
    return Definitions.contentBaseUrl2 + url;
  return Definitions.contentBaseUrl + url;
}

String fixToSecUrl(String url)
{
   var prefix = url.split('/')[1];
   url = Definitions.tapeBaseUrl.format([prefix, url]);
   return url;
}