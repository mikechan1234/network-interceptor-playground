# network-interceptor-playground

This playground is a supporting repository for the medium article on [Stubbing JSON with URLProtocol](https://medium.com/@mikechan123/stubbing-json-with-urlprotocol-e303f4a0023a).

Some improvements to this bit of source code include:
- Extending Stub to include full HTTP response information
- Changing Stub from an enum into a class to make it more open for adding endpoints
- Add other options such as authentication challenges or URL redirect in the Interceptor
