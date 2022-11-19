#!/usr/bin/env python

import argparse
from pathlib import Path

import jinja2
from boto3 import client


class ConfigGenerator:

    def __init__(self):
        self.ssm = client('ssm')

    def get_parameter(self, name: str):
        resp = self.ssm.get_parameter(
            Name=name,
            WithDecryption=True
        )
        value = resp['Parameter']['Value']
        return value

    def gen(self, src_dir: Path, dst_dir: Path):
        env = jinja2.Environment(
            loader=jinja2.FileSystemLoader(src_dir),
            undefined=jinja2.StrictUndefined
        )
        secrets = {
            'REDIS_HOST': self.get_parameter('/mastodon/redis/address'),
            'DB_HOST': self.get_parameter('/mastodon/postgres/address'),
            'DB_PASS': self.get_parameter('/mastodon/postgres/password'),
            'SMTP_LOGIN': self.get_parameter('/mastodon/ses/username'),
            'SMTP_PASSWORD': self.get_parameter('/mastodon/ses/password'),
            'VAPID_PUBLIC_KEY': self.get_parameter('/mastodon/vapid/public_key'),
            'VAPID_PRIVATE_KEY': self.get_parameter('/mastodon/vapid/private_key'),
            'SECRET_KEY_BASE': self.get_parameter('/mastodon/secret_key_base'),
            'OTP_SECRET': self.get_parameter('/mastodon/otp_secret'),
        }
        env.globals['secrets'] = secrets

        for tpl in src_dir.glob('*.j2'):
            template = env.get_template(tpl.name)
            output_path = dst_dir / tpl.name.replace('.j2', '')
            output_content = template.render()
            output_path.write_text(output_content)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('src_dir', type=Path)
    ap.add_argument('dst_dir', type=Path)
    args = ap.parse_args()

    generator = ConfigGenerator()
    generator.gen(args.src_dir, args.dst_dir)


if __name__ == '__main__':
    main()
