"""Install pinned Playwright Chromium inside this app (Python extraction avoids Node 26 unzip stall)."""
import json, pathlib, platform, urllib.request, zipfile, os
root = pathlib.Path(__file__).resolve().parent.parent
browser = next(b for b in json.loads((root/'node_modules/playwright-core/browsers.json').read_text())['browsers'] if b['name']=='chromium')
arch = platform.machine().lower()
variant = ('mac-arm64' if arch in ('arm64','aarch64') else 'mac-x64') if platform.system()=='Darwin' else 'linux64'
target=root/'.cache/ms-playwright'/('chromium-'+browser['revision'])
marker=target/'INSTALLATION_COMPLETE'
if not marker.exists():
    target.mkdir(parents=True, exist_ok=True)
    archive=root/'.cache/chromium.zip'
    urllib.request.urlretrieve(f"https://cdn.playwright.dev/builds/cft/{browser['browserVersion']}/{variant}/chrome-{variant}.zip", archive)
    with zipfile.ZipFile(archive) as z:
        for entry in z.infolist():
            z.extract(entry,target)
            mode=entry.external_attr >> 16
            if mode: os.chmod(target/entry.filename,mode)
    marker.touch()
    archive.unlink()
print('Chromium '+browser['browserVersion']+' ready in '+str(target))
