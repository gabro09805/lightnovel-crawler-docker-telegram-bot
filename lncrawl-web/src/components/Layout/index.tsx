import LncrawlImage from '@/assets/lncrawl.svg';
import { Avatar, Divider, Grid, Layout, Typography } from 'antd';
import { Outlet, useNavigate } from 'react-router-dom';
import { MobileNavbar } from './navbar';
import { MainLayoutSidebar } from './sidebar';

export const MainLayout: React.FC<any> = () => {
  const navigate = useNavigate();
  const { md } = Grid.useBreakpoint();

  return (
    <Layout>
      {md && <MainLayoutSidebar />}

      <Layout.Content
        style={{
          height: '100vh',
          overflow: 'auto',
          position: 'relative',
          padding: md ? 20 : 10,
          paddingBottom: md ? 70 : 120,
        }}
      >
        {!md && (
          <>
            <Typography.Title
              onClick={() => navigate('/')}
              level={4}
              style={{
                textAlign: 'center',
                fontSize: 18,
                margin: 0,
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
            <Divider size="small" />
          </>
        )}

        <div
          style={{
            margin: '0 auto',
            transition: 'all 0.2s ease-in-out',
            maxWidth: 1200,
            minHeight: 'calc(100% - 60px)',
          }}
        >
          <Outlet />
        </div>
      </Layout.Content>

      {!md && <MobileNavbar />}
    </Layout>
  );
};
