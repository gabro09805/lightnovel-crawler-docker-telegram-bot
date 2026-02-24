import { Divider, Grid, Layout } from 'antd';
import { Outlet } from 'react-router-dom';
import { MobileLayoutHeader } from './_header';
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
          paddingBottom: 120,
        }}
      >
        <MobileLayoutHeader />
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
