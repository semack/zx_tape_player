import 'definitions.dart';

String fixScreenShotUrl(String url)
{
  if (url.startsWith('/zxscreens'))
    return Definitions.contentBaseUrl2 + url;
  return Definitions.contentBaseUrl + url;
}

String fixDownloadShotUrl(String url)
{
  if (url.startsWith('/zxscreens'))
    return Definitions.contentBaseUrl2 + url;
  return Definitions.contentBaseUrl + url;
}