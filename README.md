## Warnings

**USE UNDER YOUR OWN RISK**

## Features
1. Work under Python 3.
2. Only support static node assignment in tokenserver (the same one used in selfhost).
3. Only support sql (sqlite/mysql/postgres) storage backend (spanner is not supported).
4. Only support passing settings from environment variables.
5. Recommend to use with [fxa-selfhosting](https://github.com/jackyzy823/fxa-selfhosting).
6. Passed function tests.

## Why
Because Mozilla haven't provide database migration scripts for upgrading to [syncstorage-rs](https://github.com/mozilla-services/syncstorage-rs) yet.

Also, Mozilla dropped [support for mysql](https://github.com/mozilla-services/syncstorage-rs/issues/1495) in [syncstorage-rs](https://github.com/mozilla-services/syncstorage-rs) docker image.

Finally, you need to [change tokenserver's uri](https://github.com/mozilla-services/syncstorage-rs/issues/1051#issuecomment-924885375) if you want to upgrade to [syncstorage-rs](https://github.com/mozilla-services/syncstorage-rs).


--------------------------
#### Adventures when upgrading from Python 2 to Python 3

1. Pyramid 

    Beacuse `mozsvc/user/__init__.py` uses `set_authorization_policy` and `set_authentication_policy`, at this time `Pyramid` will [create a default `LegacySecurityPolicy`](https://github.com/Pylons/pyramid/blob/2.0.2/src/pyramid/config/security.py#L100-L101). Then in `syncstorage/views/authentication.py`, `set_authentication_policy` is set again, However we have a security policy now, so `set_authentication_policy` will [fail](https://github.com/Pylons/pyramid/blob/2.0.2/src/pyramid/config/security.py#L95-L98).

    Resoultion: 
        
    1. `set_security_policy` to None and then do `set_authentication_policy` in `syncstorage/views/authentication.py`.

    2. According to `Pyramid`'s [release note](https://docs.pylonsproject.org/projects/pyramid/en/latest/whatsnew-2.0.html#upgrading-from-third-party-policies), create a security policy based on `SyncStorageAuthenticationPolicy` and ` ACLAuthorizationPolicy`.


2. SQLAlchemy

    In SQLAlchemy 1.4 +, `POSTCOMPILE` placeholder is used in compiled sql for `in` clause. this placeholder should be resolved only when executing. If you convert compiled sql to text (*only for adding comments*), the `POSTCOMPILE` will never be resolved.

    Resoultion: Do not convert compiled sql to text.

3. Proutes

    little trick for proutes to show routes without install packages.

    Run `` env PYTHONPATH=`pwd` proutes tests.ini `` 

    Content in `test.ini`:
    ```ini
    [server:main]
    use = egg:gunicorn
    host = 0.0.0.0
    port = 5000
    workers = 1
    timeout = 30

    [app:main]
    use = call:syncserver:main
    ```