import LncrawlImage from '@/assets/lncrawl.svg';
import { Avatar, Divider, Grid, Layout, Typography } from 'antd';
import { Outlet, useNavigate } from 'react-router-dom';
import { MobileNavbar } from './_navbar';
import { MainLayoutSidebar } from './_sidebar';

const PageContainer: React.FC<any> = () => {
  return (
    <div
      style={{
        maxWidth: 1200,
        margin: '0 auto',
        transition: 'all 0.2s ease-in-out',
      }}
    >
      <Outlet />
    </div>
  );
};

const MobileHeader: React.FC<any> = () => {
  const navigate = useNavigate();
  return (
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
  );
};

const MainLayoutDesktop: React.FC<any> = () => {
  return (
    <Layout>
      <MainLayoutSidebar
        style={{
          position: 'sticky',
          top: 0,
        }}
      />
      <Layout.Content
        style={{
          minHeight: '100vh',
          padding: 20,
          paddingBottom: 50,
          position: 'relative',
        }}
      >
        <PageContainer />
      </Layout.Content>
    </Layout>
  );
};

const MainLayoutMobile: React.FC<any> = () => {
  return (
    <Layout>
      <Layout.Content
        style={{
          minHeight: '100vh',
          position: 'relative',
          padding: 10,
          paddingBottom: 80,
        }}
      >
        <MobileHeader />
        <Divider size="small" />
        <PageContainer />
      </Layout.Content>

      <MobileNavbar />
    </Layout>
  );
};

export const MainLayout: React.FC<any> = () => {
  const { md: isDesktop } = Grid.useBreakpoint();
  if (isDesktop) {
    return <MainLayoutDesktop />;
  }
  return <MainLayoutMobile />;
};
