coming soon!


Taken from Paul's CDE workshop.
https://docs.google.com/document/d/1qqfII1i4spfGnhKd9rZKnpSgt9UIFE07WbuulGQxn-U/edit


## Assets:

```
wget https://www.cloudera.com/content/dam/www/marketing/tutorials/enrich-data-using-cloudera-data-engineering/tutorial-files.zip`
```

Unzip that, and upload the 5 `csv` files to your S3 bucket.   

`aws s3 cp . s3://<YOUR BUCKET>/PREFIX/cde_workshop/ --recursive --exclude "*" --include "*.csv"`

I put mine into `s3://goes-se-sandbox01/cnelson2/cde-workshop/`

rename the `*.py` files to begin with your username.  For me this is `cnelson2`.  Any references to that here should be changed to your username.


## CDP Resources

* CDP env
* CDE env
* CDE virtual cluster




