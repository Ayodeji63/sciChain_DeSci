import React from 'react';
import styled from '@emotion/styled';
import { Flex } from '@totejs/uikit';
import Bg from '../images/bg.png';
import Lg from '../images/proposals/pic.png';




const Home = () => {
  return <Container flexDirection={'column'} alignItems={'center'}>
     <BannerInfo>
        <img src={Bg} alt="" />
        <Info flexDirection={'column'} gap={26}>
          <Title>
            EMPOWERING<br></br> SCIENCE
          </Title>
          <SubTitle>
          Unleashing Innovation: SciChain - Where Research meets Blockchain.
          </SubTitle>
        </Info>
      </BannerInfo>
      <WorkInfo flexDirection={'column'} gap={37}>
  <WorkMainTitle>Revolutionizing Scientific Research</WorkMainTitle>
  
  <WorkItem flexDirection={'column'} gap={20}>
    <WorkTitle>Fast Collaboration</WorkTitle>
    <WorkDesc>
      SciChain enables scientists and researchers to collaborate quickly and efficiently, breaking down geographical boundaries and connecting diverse minds from around the world. This fosters a global community where collective intelligence can be harnessed to revolutionise the world of science.
    </WorkDesc>
  </WorkItem>

  <WorkItem flexDirection={'column'} gap={20}>
    <WorkTitle>Knowledge Sharing</WorkTitle>
    <WorkDesc>
    SciChain facilitates the sharing of scientific knowledge, allowing researchers to unlock the full potential of science. By embracing transparency and open communication, Molecule creates a thriving ecosystem where integrity and accountability are paramount. Researchers can freely exchange information, access valuable data, and contribute to a more equitable and fair scientific community.
    </WorkDesc>
  </WorkItem>

  <WorkItem flexDirection={'column'} gap={20}>
    <WorkTitle>Disruption of Traditional Structures</WorkTitle>
    <WorkDesc>
    SciChain disrupts traditional structures and funding models in the scientific community. By breaking down barriers and challenging norms, it enables researchers to explore new avenues of research and pursue innovative ideas. This disruptive approach encourages creativity, encourages out-of-the-box thinking, and empowers scientists to create the unknown.
    </WorkDesc>
  </WorkItem>

  <WorkItem flexDirection={'column'} gap={20}>
    <WorkTitle>Empowerment</WorkTitle>
    <WorkDesc>
    SciChain empowers scientists and researchers, giving them more control over their work and the development of life sciences. By enabling them to govern the research process, intellectual property and involve patients in decision-making, Molecule ensures that scientific breakthroughs are driven by the needs of the community. This empowerment creates a future where people have control over their own health and where scientific advancements benefit all.
    </WorkDesc>
  </WorkItem>
</WorkInfo>

  <ProposalMainTitle>Proposals</ProposalMainTitle>

  <ProposalContainer>
  <ProposalCard>
  <img src={Lg} className='img' alt="" />
  <ProposalCardContent>
  <ProposalInfo>
    <ProposalStatus>
      Longevity
    </ProposalStatus>
    <ProposalStatus>
      Fully Funded
    </ProposalStatus>
  </ProposalInfo>

  <ProposalTitle>
  SavedApe: Microbial Lipid Production with Synthetic Biology
  </ProposalTitle>
  <ProposalDesc>

SavedApe is an innovative project focused on microbial lipid production through the application of synthetic biology. Leveraging cutting-edge techniques in genetic engineering and biotechnology, SavedApe aims to enhance the efficiency of lipid synthesis within microbial organisms. 
  </ProposalDesc>
  </ProposalCardContent>
  </ProposalCard>
 
  </ProposalContainer>

  </Container>
}

export default Home;
const Container = styled(Flex)`
  margin-top: -80px;
  width: 100%;
  background-color: #1e2026;
`;

const ProposalContainer = styled(Flex) `
  flex-direction: column;

`
const BannerInfo = styled.div`
  position: relative;
  width: 100%;
  height: 564px;
  background-color: #000;
  img {
    position: absolute;
    min-width: 1440px;
    height: 564px;
    right: 0;
  }
`;

const Info = styled(Flex)`
  position: absolute;
  top: 228px;
  left: 148px;
`;

const Title = styled.div`
  font-size: 58px;
  font-weight: 400;
  line-height: 58px;
  font-family: 'Zen Dots';
`;

const SubTitle = styled.div`
  font-size: 24px;
  font-weight: 400;
  color: #b9b9bb;
`;


const WorkInfo = styled(Flex)`
  margin-top: 70px;
  width: 1200px;
  padding: 24px 40px;
`;

const WorkMainTitle = styled.div`
  text-align: center;
  font-size: 42px;
  font-weight: 700;
  color: #ffffff;
`;

const ProposalMainTitle = styled.div`
text-align: center;
font-size: 42px;
font-weight: 700;
color: #ffffff;
`;

const ProposalCard = styled.div`
text-align: center;
width: 350px;
height: 600px;
border-radius: 8px;
cursor: pointer;
background-color: #fff;
line-height: 28px;
.icon {
  margin-top: 22.3px;
}
.title {
  color: #fff;
}
.img {
  width: 100%;
  overflow: hidden;
  height: 120px;
  background-color:blue;
  border-top-left-radius: 8px;
  border-top-right-radius: 8px;

}
&:hover {
  background-color: #fff;

  .icon {
    margin-top: 22.3px;
    color: #aeafb0;
  }
  .title {
    color: #535458;
  }
}
`

const ProposalCardContent =styled.div`
display: flex;
flex-direction: column;
padding: 20px;

`

const ProposalInfo = styled.div`
display: flex;
width: 100%;
justify-content: space-around;
margin-top: 10px;
color: #000;

`
const ProposalStatus = styled.div`
 display: flex;
 border-radius: 20px;
 border-width: 2px;
 border-color: #b9b9bb;
 width: fit-content;
 height: fit-content;
 padding-inline: 15px;
 padding-bottom: 7px;
`

const ProposalTitle = styled.div`
font-size: 2rem;
text-align: left;
color: #000;
font-weight: 900;
margin-top: 15px
`

const ProposalDesc = styled.div `
font-size: 18px;
font-weight: 400;
color: #b9b9bb;
`

const WorkItem = styled(Flex)``;

const WorkTitle = styled.div`
  font-size: 24px;
  font-weight: 700;
  color: #ffffff;
`;

const WorkDesc = styled.div`
  font-size: 18px;
  font-weight: 400;
  color: #b9b9bb;
`;

const Cards = styled(Flex)`
  margin: 80px 0 114px;
  background-color: #272727;
  width: 1200px;
  height: 426px;
  border-radius: 15px;
`;

const TitleCon = styled(Flex)``;

const CardTitle = styled.div`
  font-size: 34px;
  font-weight: 700;
  color: #ffffff;
`;

const CardSubTitle = styled.div`
  font-size: 20px;
  font-weight: 400;
  color: #b9b9bb;
`;

const CardCon = styled(Flex)``;

const CardItem = styled(Flex)`
  text-align: center;
  width: 190px;
  height: 140px;
  border-radius: 8px;
  background-color: #1f2026;
  line-height: 28px;
  .icon {
    margin-top: 22.3px;
  }
  .title {
    color: #fff;
  }
  &:hover {
    background-color: #fff;

    .icon {
      margin-top: 22.3px;
      color: #aeafb0;
    }
    .title {
      color: #535458;
    }
  }
`;

const CardItemTitle = styled.div`
  font-size: 16px;
  font-weight: 700;
  color: #fff;
`;
