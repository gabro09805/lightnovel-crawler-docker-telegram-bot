import { Auth } from '@/store/_auth';
import type { User } from '@/types';
import { stringifyError } from '@/utils/errors';
import { DeleteOutlined } from '@ant-design/icons';
import { Button, Flex, Grid, message, Popconfirm } from 'antd';
import axios from 'axios';
import { useState } from 'react';
import { useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { UserEditButton } from './UserEditButton';

export const UserDetailsActions: React.FC<{
  user: User;
  onChange: () => any;
}> = ({ user, onChange }) => {
  const navigate = useNavigate();
  const { xs } = Grid.useBreakpoint();
  const authUser = useSelector(Auth.select.user);
  const [messageApi, contextHolder] = message.useMessage();

  const [deleting, setDeleting] = useState(false);

  const handleDelete = async () => {
    setDeleting(true);
    try {
      await axios.delete(`/api/user/${user.id}`);
      messageApi.success('Permanently deleted the user');
      navigate('/admin/users');
    } catch (err) {
      console.error(err);
      messageApi.error(stringifyError(err));
    } finally {
      setDeleting(false);
    }
  };

  return (
    <>
      {contextHolder}

      <Flex wrap gap={8} align="center" justify="end" style={{ marginTop: 10 }}>
        <UserEditButton
          user={user}
          block={xs}
          size="large"
          shape="round"
          onChange={onChange}
        />

        {user.id !== authUser?.id && (
          <Popconfirm
            title="Are you sure?"
            description="This will permanently delete the user."
            okText="Yes, delete"
            okType="danger"
            cancelText="Cancel"
            onConfirm={handleDelete}
          >
            <Button
              danger
              block={xs}
              size="large"
              shape="round"
              icon={<DeleteOutlined />}
              loading={deleting}
            >
              Delete User
            </Button>
          </Popconfirm>
        )}
      </Flex>
    </>
  );
};
