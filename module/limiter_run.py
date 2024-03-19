import asyncio, subprocess
from datetime import timedelta, datetime

async def monitor_ssh_connections():
    # Call the monitor_connections function or shell command
    try:
        while True:
            subprocess.run(["bash", "/etc/UDPCustom/limiter_support.sh", "monitor_connections"])
            await asyncio.sleep(300)
    except:
        print("[Conections Monitor] Any error ocurred on limiter run, contact me t.me/in0vador")
        sys.exit(0)

async def lock_expired_users():
    try:
        while True:
            subprocess.run(["bash", "/etc/UDPCustom/limiter_support.sh", "lock_expired_users"])
            now = datetime.now()
            tomorrow = now + timedelta(days=1)
            target_time = datetime(tomorrow.year, tomorrow.month, tomorrow.day, 1, 0, 0)
            time_until_target = target_time - now
            await asyncio.sleep(time_until_target.total_seconds())
    except KeyboardInterrupt:
        print("[Locker Monitor] Stopped by user")
    except:
        print("[Locker Monitor] Any error ocurred on limiter run, contact me t.me/in0vador")
        sys.exit(0)

async def main():
    ssh_task = asyncio.create_task(monitor_ssh_connections())
    expired_task = asyncio.create_task(lock_expired_users())
    await asyncio.gather(ssh_task, expired_task)

if __name__ == "__main__":
    asyncio.run(main())