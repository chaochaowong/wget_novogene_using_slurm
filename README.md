This repos includes a jupyter notebook and `sbatch` shell script to faciliate parallel downloading processes from Novogene's FTP server on SCRI's Sasquatch HPC. 

## Functions
There are two python functions on `FTP_novogene.ipynb`: 
- `get_full_path(host, user, password)`:  get directory paths for each sample for your project from Novogene's FTP server.
- `submit_subprocess_slurm(slurm_shell, full_paths, dest_path, account)`: submit one sbatch job per path (sample) via `wget_novogene.sh` 

`wget_novogene.sh` performs `wget` with settings to disable the creation of a hostname directory (`usftp21.novogene.com`) and remove top two levels of directories (i.e., `usftp21.novogene.com` and `/01.RawData/`). 


## Parameters
The users will provide your credential to Novogene's FTP server. 
```python
# parameters
host = 'usftp21.novogene.com'
user = ''
password = ''

# function
full_paths = get_full_paths(host, user, password)
```

After getting the path, you will provide your cluster account (i.e., `cpu_[your_lab]_sponser`), the destination for the downloads, the location of `wget_novogene.sh`, and your email address to get notification when the job is done. 

```python
# parameters
dest_path = os.path.join('/data/hps/assoc/private/sarthy_lab',
                         'NGS/FASTQs', 'testing_GBe11')
cluster_account = 'cpu-Sarthy_lab-sponsored'
mail_user = ''
slurm_shell = os.path.join('/data/hps/assoc/private/sarthy_lab',
                           'user/cwo11/projects',
                           'wget_novogene_using_slurm',
                           'wget_novogene.sh')
# function                           
resutls = submit_subprocess_slurm(slurm_shell = slurm_shell, 
                                  full_paths  = full_paths,
                                  dest_path   = dest_path, 
                                  mail_user   = mail_user,
                                  account     = cluster_account)                           
```
