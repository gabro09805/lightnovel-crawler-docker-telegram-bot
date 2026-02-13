import LncrawlImage from '@/assets/lncrawl.svg';
import { Avatar, Typography } from 'antd';
import { useNavigate } from 'react-router-dom';

export const MobileLayoutHeader: React.FC<any> = () => {
  const navigate = useNavigate();
  return (
    <Typography.Title
      onClick={() => navigate('/')}
      level={4}
      style={{
        textAlign: 'center',
        fontSize: 18,
        margin: 7,
      }}
    >
      <Avatar
        shape="square"
        src={LncrawlImage}
        size={24}
        style={{ paddingBottom: 3 }}
      />
      Lightnovel Crawler
    </Typography.Title>
  );
};
