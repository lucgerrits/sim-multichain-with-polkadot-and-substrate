import React, { useEffect, useState } from 'react'
import { Card, Icon, Label, Statistic } from 'semantic-ui-react'

import { useSubstrateState } from './substrate-lib'

function Main(props) {
  const { api, keyring, socket } = useSubstrateState()

  ////////////////node info
  const [nodeInfo, setNodeInfo] = useState({})
  useEffect(() => {
    const getInfo = async () => {
      try {
        const [chain, nodeName, nodeVersion] = await Promise.all([
          api.rpc.system.chain(),
          api.rpc.system.name(),
          api.rpc.system.version(),
        ])
        setNodeInfo({ chain, nodeName, nodeVersion })
      } catch (e) {
        console.error(e)
      }
    }
    getInfo()
  }, [api.rpc.system])
  ////////////////end node info


  ////////////////block info
  const { finalized } = props
  const [blockNumber, setBlockNumber] = useState(0)
  const [blockNumberTimer, setBlockNumberTimer] = useState(0)

  const bestNumber = finalized
    ? api.derive.chain.bestNumberFinalized
    : api.derive.chain.bestNumber

  useEffect(() => {
    let unsubscribeAll = null

    bestNumber(number => {
      // Append `.toLocaleString('en-US')` to display a nice thousand-separated digit.
      setBlockNumber(number.toNumber().toLocaleString('en-US'))
      setBlockNumberTimer(0)
    })
      .then(unsub => {
        unsubscribeAll = unsub
      })
      .catch(console.error)

    return () => unsubscribeAll && unsubscribeAll()
  }, [bestNumber])

  const timer = () => {
    setBlockNumberTimer(time => time + 1)
  }

  useEffect(() => {
    const id = setInterval(timer, 1000)
    return () => clearInterval(id)
  }, [])
  ////////////////end block info

  ////////////////renault info
  const [renaultInfo, setRenaultInfo] = useState({})
  useEffect(() => {
    const getInfo = async () => {
      try {
        const [factories, vehicles, vehiclesStatus] = await Promise.all([
          api.query.palletSimRenault.factories.entries(),
          api.query.palletSimRenault.vehicles.entries(),
          api.query.palletSimRenault.vehiclesStatus.entries(),
        ])
        setRenaultInfo({ factories, vehicles, vehiclesStatus })
      } catch (e) {
        console.error(e)
      }
    }
    getInfo()
  }, [api, api.rpc.state])
  ////////////////end renault info


  function ListFactories() {
    let elements = []
    if (renaultInfo.factories && renaultInfo.factories.length !== 0)
      renaultInfo.factories.map(([{ args: [accountid] }, blocknumber]) => elements.push({ accountid: accountid, blocknumber: blocknumber }))
    console.log(elements)
    return elements && elements.length !== 0 ? (
      <ul>
        {elements.map((element) =>
          <li key={element.accountid.toString()}>{element.accountid.toString()} (Block n°{element.blocknumber.toString()})</li>
        )}
      </ul>
    ) : (
      <Label basic color="yellow">
        No accounts to be shown
      </Label>
    )
  }

  return (
    <div>
      <Card.Group>
        <Card>
          <Card.Content>
            <Card.Header>{nodeInfo.nodeName}</Card.Header>
            <Card.Meta>
              <span>{nodeInfo.chain}</span>
            </Card.Meta>
            <Card.Description>{socket}</Card.Description>
          </Card.Content>
          <Card.Content extra>
            <Icon name="setting" />v{nodeInfo.nodeVersion}
          </Card.Content>
        </Card>

        <Card>
          <Card.Content textAlign="center">
            <Statistic
              className="block_number"
              label={(finalized ? 'Finalized' : 'Current') + ' Block'}
              value={blockNumber}
            />
          </Card.Content>
          <Card.Content extra>
            <Icon name="time" /> {blockNumberTimer}
          </Card.Content>
        </Card>

        <Card>
          <Card.Content>
            <Card.Header>Renault Factories</Card.Header>
            <Card.Description>
              <ListFactories />
            </Card.Description>
          </Card.Content>
          <Card.Content extra>
            <Icon name="setting" />v{nodeInfo.nodeVersion}
          </Card.Content>
        </Card>
      </Card.Group>
    </div>
  )
}

export default function SIMDashboard(props) {
  const { api } = useSubstrateState()
  return api.query.palletSimRenault &&
    api.rpc &&
    api.rpc.system &&
    api.rpc.system.chain &&
    api.rpc.system.name &&
    api.rpc.system.version &&
    api.derive &&
    api.derive.chain &&
    api.derive.chain.bestNumber &&
    api.derive.chain.bestNumberFinalized ? (
    <Main {...props} />
  ) : null
}
