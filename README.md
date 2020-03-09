# Convenience tools to run Apache Crail

This is a small collection of scripts to run and stop Apache Crail.

## Running Apache Crail from a development source tree

If you check out the [Apache Crail](http://crail.apache.org/) [source code](https://github.com/apache/incubator-crail)
for development (or just to try out), you sometimes want to quickly start it to run a small test.
The script `run_crail_from_devsrc.sh` is an easy way to just run Apache Crail from your source tree.

### Check out the source
First, check out the source code of Apache Crail

    git clone https://github.com/apache/incubator-crail
    cd incubator-crail
    . ../tools/run_crail_from_devsrc.sh
