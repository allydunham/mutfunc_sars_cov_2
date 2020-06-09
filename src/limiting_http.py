"""
Rate limiting version of Snakemake HTTP remote.
Adapted from snakemake/remote/HTTP.py at https://github.com/snakemake/snakemake
"""
import time

from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
from snakemake.remote.HTTP import RemoteObject as HTTPRemoteObject
from snakemake.logging import logger

class RemoteProvider(HTTPRemoteProvider):
    """
    Mirror Regular Snakemake HTTP remote provider, but link a different RemoteObject
    """
    def __init__(
        self, *args, keep_local=False, stay_on_remote=False, is_default=False, **kwargs
    ):
        super(RemoteProvider, self).__init__(
            *args,
            keep_local=keep_local,
            stay_on_remote=stay_on_remote,
            is_default=is_default,
            **kwargs
        )

class RemoteObject(HTTPRemoteObject):
    """
    Patched version of Snakemake HTTP Remote Object with rate limiting among all instances,
    to avoid overloading an individual server.

    The way snakemake works means these must be monkey-patched class variables. Defaults to waiting
    1 second between requests.
    """
    min_wait = 1
    _last_time = None
    def __init__(
        self,
        *args,
        keep_local=False,
        provider=None,
        additional_request_string="",
        allow_redirects=True,
        **kwargs
    ):
        super(RemoteObject, self).__init__(
            *args,
            keep_local=keep_local,
            provider=provider,
            allow_redirects=allow_redirects,
            **kwargs
        )
        self.additional_request_string = additional_request_string

    def httpr(self, verb="GET", stream=False):
        now = time.time()
        if RemoteObject._last_time is not None:
            diff = RemoteObject.min_wait - (now - RemoteObject._last_time)
            if diff > 0:
                logger.debug(f'Rate limiting for server ({diff}s)')
                time.sleep(diff)
        RemoteObject._last_time = now

        return super(RemoteObject, self).httpr(verb, stream)
