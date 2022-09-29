Navigate to your virtual cluster.   Click CLI TOOL to download it.  While you're there, copy the JOBS API URL.

On your local machine:

```
chmod +x ~/Downloads/cde
mv ~/Downloads/cde /usr/local/bin/.

mkdir ~/.cde
echo "vcluster-endpoint: PASTE_YOUR_JOBS_API_URL_HERE" > ~/.cde/configure.yaml
```

If you have the CDP CLI already configured, it will authenticate through that user configuration.   You may also need to allow your Macbook's security & privacy to allow `cde` to run.

Test it:

`cde job list`

should give you a list of the jobs on your virtual cluster.   Or an empty json payload if you dont' have any jobs yet.
