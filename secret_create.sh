# usage:
# $1 = hostname
# $2 = secretname (with .age suffix)

if [ $# -lt 2 ]; then
    # TODO: print usage
    echo "USAGE: ./secret_create.sh <hostname> <secretname>"
    echo "EXAMPLE: ./secret_create.sh corrino abc.age"
    exit 1
fi

# the path we'll use to store our secret in the end
SECRET_FILE="nix/hosts/$1/secrets/$2"

# but first, we're editing the default "new" secret
NEW_FILE="nix/hosts/$1/secrets/new"

echo "Editing the 'new' file: '$NEW_FILE'"
EDITOR=hx nix run git+https://github.com/ryantm/agenix -- -e $NEW_FILE

echo "Moving the 'new' file to the specified secret file '$2'"
mv $NEW_FILE $SECRET_FILE

echo "Adding the secret to git in order to use it"
git add $SECRET_FILE

echo "Created secret $SECRET_FILE"
