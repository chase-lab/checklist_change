## Automatic data quality testing
### Testing
These tests are ran automatically before every commit thanks to a pre-commit
hook. If some tests fail, we can cancel the `git commit`.

### Automatising
At the root of the working directory, a bash scripts calls `./tests/testthat.R`
that runs the tests.
Git knows about it because a `pre-commit` file was added inside the `./.git/hooks/`
folder. In its most basic form, this scripts contains the following lines:
```
#!/bin/sh
 Rscript tests/testthat.R

```
