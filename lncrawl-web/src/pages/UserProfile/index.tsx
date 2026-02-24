import { UserAvatar } from '@/components/Tags/UserAvatar';
import { UserRoleTag } from '@/components/Tags/UserRoleTag';
import { UserTierTag } from '@/components/Tags/UserTierTag';
import { store } from '@/store';
import { Auth } from '@/store/_auth';
import type { User } from '@/types';
import { formatDate, formatFromNow } from '@/utils/time';
import {
  CalendarOutlined,
  CrownOutlined,
  KeyOutlined,
  LockOutlined,
  MailOutlined,
  SafetyCertificateOutlined,
  UserOutlined,
} from '@ant-design/icons';
import { Descriptions, Divider, Grid, Space, Typography } from 'antd';
import axios from 'axios';
import { useEffect, useState } from 'react';
import { useSelector } from 'react-redux';
import { ProfileNameChangeButton } from './ProfileNameChangeButton';
import { ProfilePasswordChangeButton } from './ProfilePasswordChangeButton';

export const UserProfilePage: React.FC<any> = () => {
  const { xs } = Grid.useBreakpoint();
  const user = useSelector(Auth.select.user)!;
  const [token, setToken] = useState<string>();

  const updateUser = async () => {
    const result = await axios.get<User>(`/api/auth/me`);
    store.dispatch(Auth.action.setUser(result.data));
  };

  useEffect(() => {
    updateUser();
  }, []);

  useEffect(() => {
    const generateToken = async () => {
      try {
        const result = await axios.post<{ token: string }>(
          '/api/auth/me/create-token'
        );
        setToken(result.data.token);
      } catch (err) {
        console.error(err);
      }
    };
    generateToken();
  }, [user.id]);

  return (
    <div style={{ maxWidth: 800, margin: '0 auto' }}>
      <Typography.Title level={2}>
        <UserOutlined /> Profile
      </Typography.Title>

      <Descriptions
        bordered
        column={1}
        size="middle"
        layout={xs ? 'vertical' : 'horizontal'}
        styles={{ label: { width: 150, fontWeight: 500 } }}
      >
        <Descriptions.Item
          label={
            <Space>
              <UserOutlined /> Name
            </Space>
          }
        >
          <Space>
            <UserAvatar user={user} size={32} />
            <Typography.Text>{user.name}</Typography.Text>
            <Divider orientation="vertical" />
            <ProfileNameChangeButton user={user} onChange={updateUser} />
          </Space>
        </Descriptions.Item>

        <Descriptions.Item
          label={
            <Space>
              <MailOutlined /> Email
            </Space>
          }
        >
          <Typography.Text copyable>{user.email}</Typography.Text>
        </Descriptions.Item>

        <Descriptions.Item
          label={
            <Space>
              <CrownOutlined /> Tier
            </Space>
          }
        >
          <UserTierTag value={user.tier} />
        </Descriptions.Item>

        {token && (
          <Descriptions.Item
            label={
              <Space>
                <KeyOutlined /> Token
              </Space>
            }
          >
            <Space vertical size={0}>
              <Typography.Text
                copyable
                style={{ fontSize: 16, fontFamily: 'monospace' }}
              >
                {token}
              </Typography.Text>

              <Typography.Text type="secondary" style={{ fontSize: 12 }}>
                This token is valid for a limited time only.
              </Typography.Text>
            </Space>
          </Descriptions.Item>
        )}

        <Descriptions.Item
          label={
            <Space>
              <LockOutlined /> Password
            </Space>
          }
        >
          <ProfilePasswordChangeButton />
        </Descriptions.Item>

        <Descriptions.Item
          label={
            <Space>
              <CalendarOutlined /> Joined
            </Space>
          }
        >
          <Typography.Text>{formatDate(user.created_at)}</Typography.Text>
          <Divider orientation="vertical" />
          <Typography.Text type="secondary">
            {formatFromNow(user.created_at)}
          </Typography.Text>
        </Descriptions.Item>
      </Descriptions>
    </div>
  );
};
