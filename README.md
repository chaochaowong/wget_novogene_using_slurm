This repos includes a jupyter notebook and `sbatch` shell script to faciliate parallel downloading processes from Novogene's FTP server on SCRI's Sasquatch HPC. 

## Functions
There are two python functions on `FTP_novogene.ipynb`: 
- `get_full_path(host, user, password)`:  get directory paths for each sample for your project from Novogene's FTP server.
- `submit_subprocess_slurm(slurm_shell, full_paths, dest_path, account)`: submit one sbatch job per path (sample) via `wget_novogene.sh` 

`wget_novogene.sh` performs `wget` with settings to disable the creation of a hostname directory (`usftp21.novogene.com`) and remove top two levels of directories (i.e., `usftp21.novogene.com` and `/01.RawData/`). 

```python
from ftplib import FTP
import subprocess
from urllib.parse import urlparse
import os
```

```python
def get_full_paths (host, user, password):
    """
    Returns the path of the FTP server.

    Parameters: given by Novogenes
    host (str): host name
    user(str): user name
    password (str): passward

    Returns:
    str: list of folders of from FTP path
    """
    
    directory = f"ftp://{user}:{password}@{host}:21/01.RawData"
    ftp = FTP(host)
    ftp.login(user = user, passwd = password)  # omit or replace with your username and password as needed
    ftp.cwd('01.RawData')  # change to the target directory
    files = ftp.nlst() 
    full_paths = [f"{directory}/{file}" for file in files]
    ftp.quit()
    
    return (full_paths);
```

```python
def check_directory(dest_path):
    if not os.path.isdir(dest_path):
        print(f"Directory does not exist: {dest_path}")
        return False;  # Return False to indicate directory doesn't exist
    return True;  # Return True if the directory exists

def check_file_exists(file_path):
    if not os.path.isfile(file_path):
        print(f"File does not exists: {file_path}")
        return False;
    return True;

def get_last_level(ftp_url):
    parsed_url = urlparse(ftp_url)
    path = parsed_url.path
    # Split the path into its components and get the last two parts
    last_levels = '/'.join(path.strip('/').split('/')[-1:])
    return last_levels;


def submit_subprocess_slurm(slurm_shell, full_paths, dest_path, 
                            mail_user,
                            account='cpu-Sarthy_lab-sponsored'):
    """
    Returns the result of the PBS job sumission

    Parameters:
    slurm_shell (str): path to the slurm shell script
    full_paths (list str): a list of full URL of Novogene FTP folders of all samples
    dest_path (str): destination path
    account (str): sasquatch sponsored account, i.e., cpu-<assoc lab>-sponsored

    Returns:
    str: list of subprocess result
    """
    
    result =[];
    
    # sanity check dest_path and slurm_shell
    if not check_directory(dest_path):
        return;
    
    if not check_file_exists(slurm_shell):
        return;
    
    for path in full_paths:
        last_level = get_last_level(path)
        # create a subdirectory of the dest_path
        sub_dest = os.path.join(dest_path, last_level)
        # exec comment
        cmt = f"sbatch --account {account} --mail-user {mail_user} {slurm_shell} {path} {sub_dest}"
        msg = subprocess.run(cmt, shell=True, capture_output=True, text=True)
        result.append(msg);
        
    # Handling the result 
    for l in result:
        if l.returncode == 0:
            print("Command executed successfully!")
            print("Output:\n", l.stdout)
        else:
            print("Error:", result.stderr)
    return result;
    
```


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
