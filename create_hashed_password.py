import random
import hashlib

def hash_password(password, algorithm='sha1'):
    """ Hash a password using a salt.
    A salt is a random sequence added to the password string before using the
    hash function - this is used to prevent dictionary and rainbow tables
    attacks.
    For IPython, the hashed passphrase should be in the format
    'hash_algorithm:salt:hashed_password".
    """
    # Length of the salt in number of hex chars, which implies
    # salt_len * 4 bits of randomness
    salt_len = 12

    h = hashlib.new(algorithm)
    salt = ('%0' + str(salt_len) + 'x') % random.getrandbits(4*salt_len)
    h.update(password.encode('utf-8') + salt.encode('ascii'))
    
    return ':'.join(['sha1', salt, h.hexdigest()])

with open("/home/pyuser/.jupyter/jupyter_notebook_config.py", "a+") as f:
    hash_object = hash_password('pyuser')
    f.write("c.NotebookApp.password = '"+hash_object+"'")
f.close()

    
