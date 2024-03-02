import subprocess

command = "ls" # The command you want to run

subprocess.Popen(["x-terminal-emulator", "-e", f"bash -c '{command}; bash'"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

