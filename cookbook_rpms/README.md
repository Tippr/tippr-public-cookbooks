Cookbook RPMs
=============

Adding cookbooks:

- Create a file `your_cookbook/files/default/package-version.arch.rpm`.
- Create a symlink to that file named `package.arch.rpm`.
- When updating the package, delete the old package and change the symlink to the new one.
- Use `find . -type f -name '*.rpm' -exec rpm --addkeys {} +` to sign your packages before upload.

Adding signing RPMs:

- Create a data bag called `bag_keys`, and put your GPG public keys used to
  sign packages within, with contents along the lines of the following:

      {
         "id" : "cduffy_tippr",
         "key" : "-----BEGIN PGP PUBLIC KEY BLOCK-----\nVersion: GnuPG v1.4.5 (GNU/Linux)\n\nmQGiBE1VB3YRBACY9BHaAsLZFy1YLlXoMKidUh9awcnTO8AToL5We3vsqtU+8ilj\n68gjftqqiEToZguaxJexMLZukOikitOlhlTlYHpXzzLoZ7CHjDlZTfB7oadeqfKp\nbGImkNSe1N0Gt6hStpHSSqx5X8emcPBuqY3P5lwp7AAnaycaH5mLCcqipwCgy0zm\nrvsesH4IJPZh4ssYqplxr+ED+gL7lqOv69HunjOHqXi6oqy6xyaHNLPSI/No2bc4\nFRb0C9ICjg1k/rGJL8/rcef2RDf13bu3R8AAiNhzaZBGRrHzoKjNwQ8HlKOa+fHo\nf9P72vasVYR+tsZc6J3sp5SNwlWW9lqr+w/fAa48a50ymUkcfrrAjfF+XX6L0gEl\ngVqDA/9edweyThRYqDK/2cbekoduADBfkzIh7yo7YNN5pXZlU31A+kKvlG0DRZQ1\n2LSfu5DeaJSjS3smTdxEX5/+ZFfEs5kdrJ8NsN9l5PglngwCfMuxzdQQLna2zMkg\noWrwcSCziVcaCC5FfHYNvV7xD2qTFu+VBrHqMAcMpBjR9ue5ZLQvQ2hhcmxlcyBE\ndWZmeSAoVGlwcHIsIEluYy4pIDxjaGFybGVzQHRpcHByLmNvbT6IYAQTEQIAIAUC\nTVUHdgIbAwYLCQgHAwIEFQIIAwQWAgMBAh4BAheAAAoJEBqtqKjqAcqmHVAAnj7V\nSUzp2K1g04JJxWSdmobgkqqCAJwJKl80VjHAmWzaCDsSiFZMLKKLMLkCDQRNVQd/\nEAgA8I5SKIeoDz1kx2n57A24L4BBYLEy9PXCCSqiK4454wU4bh+xfbS99j/KRa8O\nyNcd04EZXtH0d0xBwGM7kOthxH9beTloHwDqd5aq0W+GxoCA/YQzc2cbNevhGEiN\nIFoLBO52l+Ki7S4tX1ji3U3Lfxpplyd71Zla2CnPfh2w6HgnxbmuKZq335y1y6QO\nVu3C2ewb7eMjCjbP3ySzZLixf6Dp1a+RwkWKi2LQgnzJ3wtT6T0g9CUsqWJ0hxj1\n0di7ftc4B1G4c575IALYWf3USueb1gQVCMg569XMU7AHGyuJ73ToIcy9sTImkQ8M\nf5IUwFrIaoisaWxxU8vGfNdq/wADBQf8CoUNr2diFp2KvRvPWMRCHc3Mx4lg00Y7\nFzYGC4n9xZUHvIidYAVgvXhIbauPb7MjjDN7IRebcrZzECCfmLXcn3JRaRHxTmL1\n5ZKptt5mgcmA0uVRTbu/YJ8v1otgkgWuZ0F0Ed8D66SSZb9x+twZAT1J/DUf9QrF\nmbsik3aTlFrnRjAzcs0D0RmhsQV/pqt9jC2zo6MTMiQIYR4maSM8MeT0gZzC2yzS\nlG+bNHAlbknENpdHOGnPRDWYqyEAHcIxSRQAXe+0G2q0+xmOJqj4X44oFQxfFF7w\n7SsFcvudWTttDhxPqjy0Ji27b0PgWhI26OOXr66JCpTKNfpQpaxc84hJBBgRAgAJ\nBQJNVQd/AhsMAAoJEBqtqKjqAcqmzIwAoJIKsV6K3DJ9GPlsOKIlKiZJ3EYZAJ9I\nGL5+bzbMaDW3s/d+PXv72W95KQ==\n=qAKq\n-----END PGP PUBLIC KEY BLOCK-----\n",
         "rpm_name" : "gpg-pubkey-ea01caa6-4d550776"
      }

  where the `rpm_name` is the name by which RPM identifies your public keys after they are installed.
